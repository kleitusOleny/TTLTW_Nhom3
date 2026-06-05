package model;

import java.sql.Timestamp;

public class ProductIssueDetail {
    private int issueId;
    private String productId;
    private String productName;
    private int quantity;
    private Timestamp createAt;
    private Timestamp updateAt;
    private boolean isDelete;
    
    public ProductIssueDetail() {
    }
    
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    
    public int getIssueId() { return issueId; }
    public void setIssueId(int issueId) { this.issueId = issueId; }
    
    public String getProductId() { return productId; }
    public void setProductId(String productId) { this.productId = productId; }
    
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    
    public Timestamp getCreateAt() { return createAt; }
    public void setCreateAt(Timestamp createAt) { this.createAt = createAt; }
    
    public Timestamp getUpdateAt() { return updateAt; }
    public void setUpdateAt(Timestamp updateAt) { this.updateAt = updateAt; }
    
    public boolean isDelete() { return isDelete; }
    public void setDelete(boolean delete) { isDelete = delete; }
}