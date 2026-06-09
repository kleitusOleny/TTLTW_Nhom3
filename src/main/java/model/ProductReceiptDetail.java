package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class ProductReceiptDetail {
    private int receiptId;
    private String productId;
    private String productName;
    private int quantity;
    private BigDecimal unitPrice;
    private Timestamp createAt;
    private Timestamp updateAt;
    private boolean isDelete;
    
    public ProductReceiptDetail() {
    }
    
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public int getReceiptId() { return receiptId; }
    public void setReceiptId(int receiptId) { this.receiptId = receiptId; }
    
    public String getProductId() { return productId; }
    public void setProductId(String productId) { this.productId = productId; }
    
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    
    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }
    
    public Timestamp getCreateAt() { return createAt; }
    public void setCreateAt(Timestamp createAt) { this.createAt = createAt; }
    
    public Timestamp getUpdateAt() { return updateAt; }
    public void setUpdateAt(Timestamp updateAt) { this.updateAt = updateAt; }
    
    public boolean isDelete() { return isDelete; }
    public void setDelete(boolean delete) { isDelete = delete; }
}