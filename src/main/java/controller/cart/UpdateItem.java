package controller.cart;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Cart;
import model.CartItem;
import model.Product;
import services.ProductService;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;

@WebServlet(name = "UpdateItem", value = "/update-item")
public class UpdateItem extends HttpServlet {
    
    ProductService productService = new ProductService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Cart cart = (Cart) request.getSession().getAttribute("cart");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
//        PrintWriter out = response.getWriter();

        if (cart == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        String id = request.getParameter("id");
        String setQuantityStr = request.getParameter("setQuantity");
        String quantityStr = request.getParameter("quantity");

        Product product = productService.getProduct(id);
        int currentStock = (product != null) ? product.getQuantity() : 0;

        int currentInCart = 0;
        for (CartItem item : cart.getItems()) {
            if (item.getProduct().getId().equals(id)) {
                currentInCart = item.getQuantity();
                break;
            }
        }

        int newQuantity = currentInCart;
        try {
            if (setQuantityStr != null) {
                newQuantity = Integer.parseInt(setQuantityStr);
            } else if (quantityStr != null) {
                int delta = Integer.parseInt(quantityStr);
                newQuantity += delta;
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }

        if (newQuantity > currentStock) {
//            out.print("{\"status\":\"error\", \"message\":\"Xin lỗi, kho chỉ còn " + currentStock + " sản phẩm.\", \"currentQuantity\":" + currentInCart + "}");
//            out.flush();
            return;
        }

        if (setQuantityStr != null) {
            cart.updateItem(id, newQuantity);
        } else if (quantityStr != null) {
            cart.updateQuantity(id, Integer.parseInt(quantityStr));
        }

//        BigDecimal itemSubtotal = BigDecimal.ZERO;
//        int finalQuantity = 0;
//
//        for (CartItem item : cart.getItems()) {
//            if (item.getProduct().getId().equals(id)) {
//                finalQuantity = item.getQuantity();
//                itemSubtotal = BigDecimal.valueOf(item.getProduct().getPrice()).multiply(BigDecimal.valueOf(finalQuantity));
//                break;
//            }
//        }
        response.sendRedirect("my-cart");

//        StringBuilder json = new StringBuilder();
//        json.append("{");
//        json.append("\"status\":\"success\",");
//        json.append("\"quantity\":").append(finalQuantity).append(",");
//        json.append("\"subtotal\":").append(itemSubtotal);
//        json.append("}");
//
//        out.print(json.toString());
//        out.flush();
//        out.close();
    
    }
}