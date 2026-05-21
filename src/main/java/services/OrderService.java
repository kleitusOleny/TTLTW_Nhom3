package services;

import dao.OrderDAO;
import model.Order;

public class OrderService {
    private final OrderDAO orderDAO = new OrderDAO();

    public int createAndReturnId(Order order) {
        return orderDAO.createAndReturnId(order);
    }
}
