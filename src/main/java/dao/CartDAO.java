package dao;

import org.jdbi.v3.core.Handle;
import java.util.List;
import java.util.Map;

public class CartDAO extends ADAO {

    private int getOrCreateCartId(int userId) {
        try (Handle handle = jdbi.open()) {
            String selectSql = "SELECT id FROM carts WHERE user_id = :userId";
            
            Integer cartId = handle.createQuery(selectSql)
                    .bind("userId", userId)
                    .mapTo(Integer.class)
                    .findFirst()
                    .orElse(null);
            
            if (cartId == null) {
                String insertSql = "INSERT INTO carts (user_id) VALUES (:userId)";
                cartId = handle.createUpdate(insertSql)
                        .bind("userId", userId)
                        .executeAndReturnGeneratedKeys("id")
                        .mapTo(Integer.class)
                        .one();
            }
            return cartId;
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi database khi lấy Cart ID: " + e.getMessage());
        }
    }
    
    public void upsertCartItem(int userId, String productId, int quantity) {
        int cartId = getOrCreateCartId(userId);
        
        String sql = "INSERT INTO cartitems (cart_id, product_id, quantity) " +
                "VALUES (:cartId, :productId, :quantity) " +
                "ON DUPLICATE KEY UPDATE quantity = quantity + :quantity";
        
        try (Handle handle = jdbi.open()) {
            handle.createUpdate(sql)
                    .bind("cartId", cartId)
                    .bind("productId", productId)
                    .bind("quantity", quantity)
                    .execute();
        }
    }
    
    public void updateCartItem(int userId, String productId, int quantity) {
        String sql = "UPDATE cartitems ci " +
                "JOIN carts c ON ci.cart_id = c.id " +
                "SET ci.quantity = :quantity " +
                "WHERE c.user_id = :userId AND ci.product_id = :productId";
        
        try (Handle handle = jdbi.open()) {
            handle.createUpdate(sql)
                    .bind("userId", userId)
                    .bind("productId", productId)
                    .bind("quantity", quantity)
                    .execute();
        }
    }
    
    public void removeCartItem(int userId, String productId) {
        String sql = "DELETE ci FROM cartitems ci " +
                "JOIN carts c ON ci.cart_id = c.id " +
                "WHERE c.user_id = :userId AND ci.product_id = :productId";
        
        try (Handle handle = jdbi.open()) {
            handle.createUpdate(sql)
                    .bind("userId", userId)
                    .bind("productId", productId)
                    .execute();
        }
    }
    
    public void clearCart(int userId) {
        String sql = "DELETE ci FROM cartitems ci " +
                "JOIN carts c ON ci.cart_id = c.id " +
                "WHERE c.user_id = :userId";
        
        try (Handle handle = jdbi.open()) {
            handle.createUpdate(sql)
                    .bind("userId", userId)
                    .execute();
        }
    }
    
    public List<Map<String, Object>> getCartByUserId(int userId) {
        String sql = "SELECT ci.product_id, ci.quantity FROM cartitems ci " +
                "JOIN carts c ON ci.cart_id = c.id " +
                "WHERE c.user_id = :userId";
        
        try (Handle handle = jdbi.open()) {
            return handle.createQuery(sql)
                    .bind("userId", userId)
                    .mapToMap()
                    .list();
        }
    }
}