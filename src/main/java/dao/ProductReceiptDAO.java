package dao;

import model.ProductReceipt;
import model.ProductReceiptDetail;
import org.jdbi.v3.sqlobject.config.RegisterBeanMapper;
import org.jdbi.v3.sqlobject.customizer.Bind;
import org.jdbi.v3.sqlobject.customizer.BindBean;
import org.jdbi.v3.sqlobject.statement.GetGeneratedKeys;
import org.jdbi.v3.sqlobject.statement.SqlBatch;
import org.jdbi.v3.sqlobject.statement.SqlQuery;
import org.jdbi.v3.sqlobject.statement.SqlUpdate;
import org.jdbi.v3.sqlobject.transaction.Transaction;

import java.util.List;

@RegisterBeanMapper(ProductReceipt.class)
@RegisterBeanMapper(ProductReceiptDetail.class)
public interface ProductReceiptDAO {
    
    // 1. Lưu phiếu nhập và lấy ID vừa tạo
    @SqlUpdate("INSERT INTO product_receipts (user_id, supplier_id, total_amount, note, create_at, update_at) VALUES (:userId, :supplierId, :totalAmount, :note, NOW(), NOW())")
    @GetGeneratedKeys("id")
    int insertReceipt(@BindBean ProductReceipt receipt);
    
    // 2. Lưu danh sách chi tiết phiếu nhập (sử dụng SqlBatch để tối ưu tốc độ)
    @SqlBatch("INSERT INTO product_receipt_details (receipt_id, product_id, quantity, unit_price, create_at, update_at) VALUES (:receiptId, :productId, :quantity, :unitPrice, NOW(), NOW())")
    void insertReceiptDetails(@BindBean Iterable<ProductReceiptDetail> details, @Bind("receiptId") int receiptId);
    
    // 3. Cập nhật tăng số lượng (stock) cho bảng products
    @SqlBatch("UPDATE products SET quantity = quantity + :quantity WHERE id = :productId")
    void updateProductQuantities(@BindBean Iterable<ProductReceiptDetail> details);
    
    @Transaction
    default void processReceipt(ProductReceipt receipt) {
        if (receipt.getDetails() == null || receipt.getDetails().isEmpty()) {
            throw new IllegalArgumentException("Phiếu nhập kho phải có ít nhất một sản phẩm.");
        }
        
        // Bước 1: Lưu phiếu nhập
        int receiptId = insertReceipt(receipt);
        
        // Bước 2: Lưu chi tiết phiếu nhập với ID vừa được cấp
        insertReceiptDetails(receipt.getDetails(), receiptId);
        
        // Bước 3: Tăng số lượng hàng trong kho
        updateProductQuantities(receipt.getDetails());
    }
    
    @SqlQuery("SELECT pr.*, COALESCE(NULLIF(u.full_name, ''), u.username) AS creatorName, m.manufacturer_name AS supplierName FROM product_receipts pr LEFT JOIN users u ON pr.user_id = u.id LEFT JOIN manufacturers m ON pr.supplier_id = m.id WHERE pr.is_delete = 0 ORDER BY pr.create_at DESC")
    List<ProductReceipt> findAllActive();
    
    @SqlQuery("SELECT prd.*, p.product_name FROM product_receipt_details prd JOIN products p ON prd.product_id = p.id WHERE prd.receipt_id = :receiptId AND prd.is_delete = 0")
    List<ProductReceiptDetail> findDetailsByReceiptId(@Bind("receiptId") int receiptId);

    @SqlQuery("SELECT pr.*, COALESCE(NULLIF(u.full_name, ''), u.username) AS creatorName, m.manufacturer_name AS supplierName FROM product_receipts pr LEFT JOIN users u ON pr.user_id = u.id LEFT JOIN manufacturers m ON pr.supplier_id = m.id WHERE pr.id = :id AND pr.is_delete = 0")
    ProductReceipt findById(@Bind("id") int id);

    @Transaction
    default ProductReceipt getReceiptWithDetails(int id) {
        ProductReceipt receipt = findById(id);
        if (receipt != null) {
            receipt.setDetails(findDetailsByReceiptId(id));
        }
        return receipt;
    }
}