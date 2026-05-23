package services;

import dao.CartDAO;
import model.Cart;
import model.CartItem;
import model.Product;
import model.User;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import java.util.Map;

public class CartSyncService {
    private CartDAO cartDAO = new CartDAO();
    private ProductService productService = new ProductService();
    
    public void syncCart(User user, HttpSession session) {
        Cart sessionCart = (Cart) session.getAttribute("cart");
        int userId = user.getId();
        
        // 1. Lưu các sản phẩm từ Session (khách chưa đăng nhập) xuống DB
        if (sessionCart != null && !sessionCart.getItems().isEmpty()) {
            for (CartItem item : sessionCart.getItems()) {
                cartDAO.upsertCartItem(userId, item.getProduct().getId(), item.getQuantity());
            }
        }
        
        // 2. Kéo danh sách giỏ hàng đã gộp từ DB lên
        List<Map<String, Object>> dbCart = cartDAO.getCartByUserId(userId);
        Cart newCart = new Cart();
        
        // 3. Tái tạo lại Session Cart với số lượng mới nhất
        for (Map<String, Object> row : dbCart) {
            String productId = (String) row.get("product_id");
            int quantity = ((Number) row.get("quantity")).intValue();
            Product product = productService.getProduct(productId);
            if (product != null) {
                newCart.addItem(product, quantity);
            }
        }
        
        session.setAttribute("cart", newCart);
    }
}