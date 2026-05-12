package dao;

import model.OrderItem;

import java.util.List;
import java.util.Objects;
import java.util.Optional;

public class OrderItemDAO extends ADAO implements IDAO<OrderItem, Integer> {

    public List<OrderItem> search(String keyword) {
        return jdbi.withHandle(handle ->
                handle.createQuery("""
                                SELECT order_id, product_id, quantity, unit_price FROM order_items
                                WHERE product_id LIKE :kw
                                """)
                        .bind("kw", "%" + keyword + "%")
                        .mapToBean(OrderItem.class)
                        .list()
        );
    }

    public List<OrderItem> getByOrderId(int orderId) {
        return jdbi.withHandle(handle ->
                handle.createQuery("""
                                SELECT  order_id, product_id, quantity, unit_price FROM order_items
                                WHERE order_id = :oid
                                """)
                        .bind("oid", orderId)
                        .mapToBean(OrderItem.class)
                        .list()
        );
    }

    public boolean deleteByOrderId(int orderId) {
        return jdbi.withHandle(handle ->
                handle.createUpdate("""
                                DELETE FROM order_items
                                WHERE order_id = :oid
                                """)
                        .bind("oid", orderId)
                        .execute() > 0
        );
    }

    @Override
    public List<OrderItem> findAll() {
        return jdbi.withHandle(handle ->
                handle.createQuery("SELECT  order_id, product_id, quantity, unit_price FROM order_items")
                        .mapToBean(OrderItem.class)
                        .list()
        );
    }

    @Override
    public Optional<OrderItem> findById(Integer integer) {
        Optional<OrderItem> item = this.findById(integer);
        int idOrder = item.get().getOrderId();
        String idProduct = item.get().getProductId();
        return Optional.of(jdbi.withHandle(handle ->
                Objects.requireNonNull(handle.createQuery("""
                                SELECT  order_id, product_id, quantity, unit_price FROM order_items
                                WHERE order_id = :oid AND product_id = :pid
                                """)
                        .bind("oid", idOrder)
                        .bind("pid", idProduct)
                        .mapToBean(OrderItem.class)
                        .findFirst()
                        .orElse(null))
        ));
    }

    @Override
    public OrderItem save(OrderItem entity) {

        return jdbi.withHandle(handle -> {

            boolean exists = handle.createQuery("""
                                SELECT COUNT(*)
                                FROM order_items
                                WHERE order_id = :oid
                                  AND product_id = :pid
                            """)
                    .bind("oid", entity.getOrderId())
                    .bind("pid", entity.getProductId())
                    .mapTo(Integer.class)
                    .one() > 0;

            String sql = exists
                    ? """
                      UPDATE order_items
                      SET quantity = :qty,
                          unit_price = :price
                      WHERE order_id = :oid
                        AND product_id = :pid
                    """
                    : """
                      INSERT INTO order_items
                      (order_id, product_id, quantity, unit_price)
                      VALUES
                      (:oid, :pid, :qty, :price)
                    """;

            int affectedRows = handle.createUpdate(sql)
                    .bind("oid", entity.getOrderId())
                    .bind("pid", entity.getProductId())
                    .bind("qty", entity.getQuantity())
                    .bind("price", entity.getUnitPrice())
                    .execute();

            return affectedRows > 0 ? entity : null;
        });
    }

    @Override
    public boolean deleteById(Integer integer) {
        Optional<OrderItem> item = this.findById(integer);
        int idOrder = item.get().getOrderId();
        String idProduct = item.get().getProductId();
        jdbi.withHandle(handle ->
                handle.createUpdate("""
                                DELETE FROM order_items
                                WHERE order_id = :oid AND product_id = :pid
                                """)
                        .bind("oid", idOrder)
                        .bind("pid", idProduct)
                        .execute() > 0
        );
        return false;
    }

    @Override
    public boolean existsById(Integer integer) {
        return this.findById(integer).isPresent();
    }
}
