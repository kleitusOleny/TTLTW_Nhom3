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
    @SqlUpdate("INSERT INTO product_receipts (user_id, supplier_id, total_amount, note) VALUES (:userId, :supplierId, :totalAmount, :note)")
    @GetGeneratedKeys("id")
    int insertReceipt(@BindBean ProductReceipt receipt);
    
    // 2. Lưu danh sách chi tiết phiếu nhập (sử dụng SqlBatch để tối ưu tốc độ)
    @SqlBatch("INSERT INTO product_receipt_details (receipt_id, product_id, quantity, unit_price) VALUES (:receiptId, :productId, :quantity, :unitPrice)")
    void insertReceiptDetails(@BindBean Iterable<ProductReceiptDetail> details, @Bind("receiptId") int receiptId);
    
    // 3. Cập nhật tăng số lượng (stock) cho bảng products
    @SqlBatch("UPDATE products SET quantity = quantity + :quantity WHERE id = :productId")
    void updateProductQuantities(@BindBean Iterable<ProductReceiptDetail> details);
    
    // Luồng thực thi chính bao bọc bởi Transaction
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
    
    @SqlQuery("SELECT * FROM product_receipts WHERE is_delete = 0 ORDER BY create_at DESC")
    List<ProductReceipt> findAllActive();
}