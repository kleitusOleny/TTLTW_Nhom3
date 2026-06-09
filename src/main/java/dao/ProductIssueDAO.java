package dao;

import model.ProductIssue;
import model.ProductIssueDetail;
import org.jdbi.v3.sqlobject.config.RegisterBeanMapper;
import org.jdbi.v3.sqlobject.customizer.Bind;
import org.jdbi.v3.sqlobject.customizer.BindBean;
import org.jdbi.v3.sqlobject.statement.GetGeneratedKeys;
import org.jdbi.v3.sqlobject.statement.SqlQuery;
import org.jdbi.v3.sqlobject.statement.SqlUpdate;
import org.jdbi.v3.sqlobject.transaction.Transaction;

import java.util.List;

@RegisterBeanMapper(ProductIssue.class)
@RegisterBeanMapper(ProductIssueDetail.class)
public interface ProductIssueDAO {
    
    // 1. Thêm mới phiếu xuất kho và lấy ID vừa tạo
    @SqlUpdate("INSERT INTO product_issues (user_id, order_id, reason, note, create_at, update_at) VALUES (:userId, :orderId, :reason, :note, NOW(), NOW())")
    @GetGeneratedKeys("id")
    int insertIssue(@BindBean ProductIssue issue);
    
    // 2. Thêm mới chi tiết dòng sản phẩm xuất kho
    @SqlUpdate("INSERT INTO product_issue_details (issue_id, product_id, quantity, create_at, update_at) VALUES (:issueId, :productId, :quantity, NOW(), NOW())")
    void insertIssueDetail(@Bind("issueId") int issueId, @BindBean ProductIssueDetail detail);
    
    // 3. Trừ số lượng tồn kho sản phẩm (Chỉ thực hiện thành công nếu số lượng hiện tại lớn hơn hoặc bằng lượng cần xuất)
    @SqlUpdate("UPDATE products SET quantity = quantity - :quantity WHERE id = :productId AND quantity >= :quantity AND is_delete = 0")
    int decreaseProductStock(@BindBean ProductIssueDetail detail);

    @Transaction
    default void processIssue(ProductIssue issue) {
        if (issue.getDetails() == null || issue.getDetails().isEmpty()) {
            throw new IllegalArgumentException("Phiếu xuất kho phải có ít nhất một dòng sản phẩm.");
        }
        
        int issueId = insertIssue(issue);
        
        for (ProductIssueDetail detail : issue.getDetails()) {

            int rowsUpdated = decreaseProductStock(detail);
            
            if (rowsUpdated == 0) {
                throw new IllegalStateException("Xuất kho thất bại: Sản phẩm mã '" + detail.getProductId() + "' không tồn tại hoặc không đủ số lượng trong kho.");
            }
            
            insertIssueDetail(issueId, detail);
        }
    }
    
    @SqlQuery("SELECT pi.*, COALESCE(NULLIF(u.full_name, ''), u.username) AS creatorName FROM product_issues pi LEFT JOIN users u ON pi.user_id = u.id WHERE pi.is_delete = 0 ORDER BY pi.create_at DESC")
    List<ProductIssue> findAllActive();
    
    @SqlQuery("SELECT pid.*, p.product_name FROM product_issue_details pid JOIN products p ON pid.product_id = p.id WHERE pid.issue_id = :issueId AND pid.is_delete = 0")
    List<ProductIssueDetail> findDetailsByIssueId(@Bind("issueId") int issueId);

    @SqlUpdate("UPDATE product_issues SET is_delete = 1 WHERE order_id = :orderId")
    void deleteByOrderId(@Bind("orderId") int orderId);

    @SqlQuery("SELECT pi.*, COALESCE(NULLIF(u.full_name, ''), u.username) AS creatorName FROM product_issues pi LEFT JOIN users u ON pi.user_id = u.id WHERE pi.id = :id AND pi.is_delete = 0")
    ProductIssue findById(@Bind("id") int id);

    @Transaction
    default ProductIssue getIssueWithDetails(int id) {
        ProductIssue issue = findById(id);
        if (issue != null) {
            issue.setDetails(findDetailsByIssueId(id));
        }
        return issue;
    }
}