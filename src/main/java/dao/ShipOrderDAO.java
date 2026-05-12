package dao;

import model.ShipOrder;

import java.util.List;
import java.util.Objects;
import java.util.Optional;

public class ShipOrderDAO extends ADAO implements IDAO<ShipOrder, Integer> {


    public List<ShipOrder> search(String keyword) {
        return jdbi.withHandle(handle ->
                handle.createQuery("""
                                SELECT ship_id, order_id, carrier_name, tracking_number, shipping_fee, status, estimated_delivery_date FROM ship_orders
                                WHERE carrier_name LIKE :kw
                                OR tracking_number LIKE :kw
                                OR status LIKE :kw
                                """)
                        .bind("kw", "%" + keyword + "%")
                        .mapToBean(ShipOrder.class)
                        .list()
        );
    }


    public ShipOrder getByOrderId(int orderId) {
        return jdbi.withHandle(handle ->
                Objects.requireNonNull(handle.createQuery("SELECT ship_id, order_id, carrier_name, tracking_number, shipping_fee, status, estimated_delivery_date FROM ship_orders WHERE order_id = :oid")
                        .bind("oid", orderId)
                        .mapToBean(ShipOrder.class)
                        .findFirst()
                        .orElse(null))
        );
    }

    public boolean updateStatus(int orderId, String status) {
        return jdbi.withHandle(handle ->
                handle.createUpdate("""
                                UPDATE ship_orders
                                SET status = :status
                                WHERE order_id = :oid
                                """)
                        .bind("status", status)
                        .bind("oid", orderId)
                        .execute() > 0
        );
    }

    public ShipOrder findByTracking(String trackingNumber) {
        return jdbi.withHandle(handle ->
                Objects.requireNonNull(handle.createQuery("SELECT ship_id, order_id, carrier_name, tracking_number, shipping_fee, status, estimated_delivery_date FROM ship_orders WHERE tracking_number = :tn")
                        .bind("tn", trackingNumber)
                        .mapToBean(ShipOrder.class)
                        .findFirst()
                        .orElse(null))
        );
    }

    @Override
    public List<ShipOrder> findAll() {
        return jdbi.withHandle(handle ->
                handle.createQuery("SELECT ship_id, order_id, carrier_name, tracking_number, shipping_fee, status, estimated_delivery_date FROM ship_orders")
                        .mapToBean(ShipOrder.class)
                        .list()
        );
    }

    @Override
    public Optional<ShipOrder> findById(Integer integer) {
        return Optional.of(jdbi.withHandle(handle ->
                Objects.requireNonNull(handle.createQuery("SELECT ship_id, order_id, carrier_name, tracking_number, shipping_fee, status, estimated_delivery_date FROM ship_orders WHERE id = :id")
                        .bind("id", integer)
                        .mapToBean(ShipOrder.class)
                        .findFirst()
                        .orElse(null))
        ));
    }

    @Override
    public ShipOrder save(ShipOrder entity) {

        return jdbi.withHandle(handle -> {

            boolean exists = this.existsById(entity.getId());

            String sql = exists
                    ? """
                      UPDATE ship_orders SET
                          order_id = :order_id,
                          carrier_name = :carrier_name,
                          tracking_number = :tracking_number,
                          shipping_fee = :shipping_fee,
                          status = :status,
                          estimated_delivery_date = :estimated_delivery_date
                      WHERE id = :id
                    """
                    : """
                      INSERT INTO ship_orders
                      (
                          order_id,
                          carrier_name,
                          tracking_number,
                          shipping_fee,
                          status,
                          estimated_delivery_date
                      )
                      VALUES
                      (
                          :order_id,
                          :carrier_name,
                          :tracking_number,
                          :shipping_fee,
                          :status,
                          :estimated_delivery_date
                      )
                    """;

            var update = handle.createUpdate(sql)
                    .bind("order_id", entity.getOrderId())
                    .bind("carrier_name", entity.getCarrierName())
                    .bind("tracking_number", entity.getTrackingNumber())
                    .bind("shipping_fee", entity.getShippingFee())
                    .bind("status", entity.getStatus())
                    .bind("estimated_delivery_date", entity.getEstimatedDeliveryDate());

            if (exists) {
                update.bind("id", entity.getId());
            }

            int affectedRows = update.execute();

            return affectedRows > 0 ? entity : null;
        });
    }

    @Override
    public boolean deleteById(Integer integer) {
        jdbi.withHandle(handle ->
                handle.createUpdate("DELETE FROM ship_orders WHERE id = :id")
                        .bind("id", integer)
                        .execute() > 0
        );
        return false;
    }

    @Override
    public boolean existsById(Integer integer) {
        return this.findById(integer).isPresent();
    }
}
