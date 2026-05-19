package services;

import dao.OrderItemDAO;
import model.OrderItem;

public class OrderItemService {
    private final OrderItemDAO orderItemDAO = new OrderItemDAO();

    public OrderItem save(OrderItem item) {
        return orderItemDAO.save(item);
    }
}
