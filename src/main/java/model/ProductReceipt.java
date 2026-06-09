package model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

public class ProductReceipt {
    private int id;
    private int userId;
    private Integer supplierId;
    private BigDecimal totalAmount;
    private String note;
    private Timestamp createAt;
    private Timestamp updateAt;
    private boolean isDelete;
    
    // Danh sách chi tiết phiếu nhập
    private List<ProductReceiptDetail> details;
    
    private String creatorName;
    private String supplierName;
    
    public ProductReceipt() {
    }
    
    public String getCreatorName() { return creatorName; }
    public void setCreatorName(String creatorName) { this.creatorName = creatorName; }
    
    public String getSupplierName() { return supplierName; }
    public void setSupplierName(String supplierName) { this.supplierName = supplierName; }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public Integer getSupplierId() { return supplierId; }
    public void setSupplierId(Integer supplierId) { this.supplierId = supplierId; }
    
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    
    public Timestamp getCreateAt() { return createAt; }
    public void setCreateAt(Timestamp createAt) { this.createAt = createAt; }
    
    public Timestamp getUpdateAt() { return updateAt; }
    public void setUpdateAt(Timestamp updateAt) { this.updateAt = updateAt; }
    
    public boolean isDelete() { return isDelete; }
    public void setDelete(boolean delete) { isDelete = delete; }
    
    public List<ProductReceiptDetail> getDetails() { return details; }
    public void setDetails(List<ProductReceiptDetail> details) { this.details = details; }
}