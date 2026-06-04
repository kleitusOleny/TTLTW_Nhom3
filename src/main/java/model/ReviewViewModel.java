package model;

import org.jdbi.v3.core.mapper.reflect.ColumnName;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;

public class ReviewViewModel {
    private int id;
    private String content;
    private double star;
    private LocalDateTime createAt;
    private LocalDateTime updateAt;
    private LocalDateTime isDelete;
    private String productId;
    private int userId;
    private String userName;
    private String userEmail;
    private String productName;
    private String imagePath;

    public ReviewViewModel() {
    }

    public int getId() {
        return id;
    }

    @ColumnName("id")
    public void setId(int id) {
        this.id = id;
    }

    public String getContent() {
        return content;
    }

    @ColumnName("content")
    public void setContent(String content) {
        this.content = content;
    }

    public double getStar() {
        return star;
    }

    @ColumnName("star")
    public void setStar(double star) {
        this.star = star;
    }

    public LocalDateTime getCreateAt() {
        return createAt;
    }
    
    public Date getCreateAtDate() {
        if (createAt == null) return null;
        return Date.from(createAt.atZone(ZoneId.systemDefault()).toInstant());
    }

    @ColumnName("create_at")
    public void setCreateAt(LocalDateTime createAt) {
        this.createAt = createAt;
    }

    public LocalDateTime getUpdateAt() {
        return updateAt;
    }

    @ColumnName("update_at")
    public void setUpdateAt(LocalDateTime updateAt) {
        this.updateAt = updateAt;
    }

    public LocalDateTime getIsDelete() {
        return isDelete;
    }

    @ColumnName("is_delete")
    public void setIsDelete(LocalDateTime isDelete) {
        this.isDelete = isDelete;
    }

    public boolean isDeleted() {
        return isDelete != null;
    }

    public String getProductId() {
        return productId;
    }

    @ColumnName("product_id")
    public void setProductId(String productId) {
        this.productId = productId;
    }

    public int getUserId() {
        return userId;
    }

    @ColumnName("user_id")
    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    @ColumnName("user_name")
    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserEmail() {
        return userEmail;
    }

    @ColumnName("user_email")
    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public String getProductName() {
        return productName;
    }

    @ColumnName("product_name")
    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getStarDisplay() {
        StringBuilder sb = new StringBuilder();
        int fullStars = (int) star;
        for (int i = 0; i < fullStars; i++) {
            sb.append("★");
        }
        for (int i = fullStars; i < 5; i++) {
            sb.append("☆");
        }
        return sb.toString();
    }

    public String getImagePath() {
        return imagePath;
    }

    @ColumnName("image_path")
    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    @Override
    public String toString() {
        return "ReviewViewModel{" +
                "id=" + id +
                ", content='" + content + '\'' +
                ", star=" + star +
                ", createAt=" + createAt +
                ", productId='" + productId + '\'' +
                ", userId=" + userId +
                ", userName='" + userName + '\'' +
                ", productName='" + productName + '\'' +
                '}';
    }
}
