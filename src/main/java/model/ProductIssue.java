package model;

import java.sql.Timestamp;
import java.util.List;

public class ProductIssue {
    private int id;
    private int userId;
    private Integer orderId;
    private String reason;
    private String note;
    private Timestamp createAt;
    private Timestamp updateAt;
    private boolean isDelete;
    
    private List<ProductIssueDetail> details;
    
    public ProductIssue() {
    }
    
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public Integer getOrderId() { return orderId; }
    public void setOrderId(Integer orderId) { this.orderId = orderId; }
    
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    
    public Timestamp getCreateAt() { return createAt; }
    public void setCreateAt(Timestamp createAt) { this.createAt = createAt; }
    
    public Timestamp getUpdateAt() { return updateAt; }
    public void setUpdateAt(Timestamp updateAt) { this.updateAt = updateAt; }
    
    public boolean isDelete() { return isDelete; }
    public void setDelete(boolean delete) { isDelete = delete; }
    
    public List<ProductIssueDetail> getDetails() { return details; }
    public void setDetails(List<ProductIssueDetail> details) { this.details = details; }
}