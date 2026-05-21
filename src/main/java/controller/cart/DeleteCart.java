package controller.cart;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Cart;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;

@WebServlet(name = "DeleteCart", value = "/delete-cart")
public class DeleteCart extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String[] listIds = request.getParameterValues("listId");
        String[] ids = request.getParameterValues("id");
        String isAjax = request.getParameter("ajax");
        
        Cart cart = (Cart) request.getSession().getAttribute("cart");
        
        if (cart != null) {
            if (listIds != null && listIds.length > 0) {
                for (String item : listIds) {
                    String[] splitIds = item.split(",");
                    for (String splitId : splitIds) {
                        if (!splitId.trim().isEmpty()) {
                            cart.removeItem(splitId.trim());
                        }
                    }
                }
            }
            else if (ids != null && ids.length > 0) {
                for (String singleId : ids) {
                    if (!singleId.trim().isEmpty()) {
                        cart.removeItem(singleId.trim());
                    }
                }
            }
        }
        
        // Trả về kết quả
        if ("true".equals(isAjax)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();
            
            BigDecimal total = BigDecimal.ZERO;
            if (cart != null) {
                total = new BigDecimal(String.valueOf(cart.getTotal()));
            }
            
            out.print("{\"total\":" + total + "}");
            out.flush();
            out.close();
        } else {
            response.sendRedirect("my-cart");
        }
    }

}