package dao;

import java.util.List;
import java.util.Map;
import java.util.Objects;

public class CartDAO extends ADAO {
    
    // Hàm phụ: Lấy ID giỏ hàng của user, nếu chưa có thì tạo mới
    private int getOrCreateCartId(int userId) {
        String selectSql = "SELECT id FROM carts WHERE user_id = :userId";
        Integer cartId = jdbi.withHandle(handle ->
                Objects.requireNonNull(handle.createQuery(selectSql)
                        .bind("userId", userId)
                        .mapTo(Integer.class)
                        .findFirst()
                        .orElse(null))
        );
        
        if (cartId == null) {
            String insertSql = "INSERT INTO carts (user_id) VALUES (:userId)";
            cartId = jdbi.withHandle(handle ->
                    handle.createUpdate(insertSql)
                            .bind("userId", userId)
                            .executeAndReturnGeneratedKeys("id")
                            .mapTo(Integer.class)
                            .one()
            );
        }
        return cartId;
    }
    
    public void upsertCartItem(int userId, String productId, int quantity) {
        int cartId = getOrCreateCartId(userId);
        
        String sql = "INSERT INTO cartitems (cart_id, product_id, quantity) " +
                "VALUES (:cartId, :productId, :quantity) " +
                "ON DUPLICATE KEY UPDATE quantity = quantity + :quantity";
        
        jdbi.withHandle(handle ->
                handle.createUpdate(sql)
                        .bind("cartId", cartId)
                        .bind("productId", productId)
                        .bind("quantity", quantity)
                        .execute()
        );
    }
    
    public void updateCartItem(int userId, String productId, int quantity) {
        String sql = "UPDATE cartitems ci " +
                "JOIN carts c ON ci.cart_id = c.id " +
                "SET ci.quantity = :quantity " +
                "WHERE c.user_id = :userId AND ci.product_id = :productId";
        
        jdbi.withHandle(handle ->
                handle.createUpdate(sql)
                        .bind("userId", userId)
                        .bind("productId", productId)
                        .bind("quantity", quantity)
                        .execute()
        );
    }
    
    public void removeCartItem(int userId, String productId) {
        String sql = "DELETE ci FROM cartitems ci " +
                "JOIN carts c ON ci.cart_id = c.id " +
                "WHERE c.user_id = :userId AND ci.product_id = :productId";
        
        jdbi.withHandle(handle ->
                handle.createUpdate(sql)
                        .bind("userId", userId)
                        .bind("productId", productId)
                        .execute()
        );
    }
    
    public void clearCart(int userId) {
        String sql = "DELETE ci FROM cartitems ci " +
                "JOIN carts c ON ci.cart_id = c.id " +
                "WHERE c.user_id = :userId";
        
        jdbi.withHandle(handle ->
                handle.createUpdate(sql)
                        .bind("userId", userId)
                        .execute()
        );
    }
    
    public List<Map<String, Object>> getCartByUserId(int userId) {
        String sql = "SELECT ci.product_id, ci.quantity FROM cartitems ci " +
                "JOIN carts c ON ci.cart_id = c.id " +
                "WHERE c.user_id = :userId";
        
        return jdbi.withHandle(handle ->
                handle.createQuery(sql)
                        .bind("userId", userId)
                        .mapToMap()
                        .list()
        );
    }
}