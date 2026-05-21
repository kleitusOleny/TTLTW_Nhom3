package dao;

import model.Payment;

import java.util.List;
import java.util.Objects;
import java.util.Optional;

public class PaymentDAO extends ADAO implements IDAO<Payment, Integer> {


    public Payment findByOrderId(int orderId) {
        if (orderId <= 0) {
            return null;
        }
        return jdbi.withHandle(handle -> handle.createQuery("SELECT id, order_id, pay_strategy, status, amount, paid_at FROM payments WHERE order_id = :orderId")
                .bind("orderId", orderId)
                .mapToBean(Payment.class)
                .findFirst()
                .orElse(null));
    }

    @Override
    public List<Payment> findAll() {
        return jdbi.withHandle(handle -> handle.createQuery("SELECT id, order_id, pay_strategy, status, amount, paid_at FROM payments")
                .mapToBean(Payment.class)
                .list());
    }

    @Override
    public Optional<Payment> findById(Integer integer) {
        if (integer == null || integer <= 0) {
            return Optional.empty();
        }
        Payment payment = jdbi.withHandle(handle -> handle.createQuery("SELECT id, order_id, pay_strategy, status, amount, paid_at FROM payments WHERE id = :id")
                .bind("id", integer)
                .mapToBean(Payment.class)
                .findFirst()
                .orElse(null));
        return Optional.ofNullable(payment);
    }

    @Override
    public Payment save(Payment entity) {
        return jdbi.withHandle(handle -> {
            boolean exists = this.existsById(entity.getId());
            String sql = exists
                    ? """
                      UPDATE payments SET
                          order_id = :orderId,
                          pay_strategy = :payStrategy,
                          status = :status,
                          amount = :amount,
                          paid_at = :paidAt
                      WHERE id = :id
                    """
                    : """
                      INSERT INTO payments
                      (
                          order_id,
                          pay_strategy,
                          status,
                          amount,
                          paid_at
                      )
                      VALUES
                      (
                          :orderId,
                          :payStrategy,
                          :status,
                          :amount,
                          :paidAt
                      )
                    """;

            var update = handle.createUpdate(sql)
                    .bind("orderId", entity.getOrderId())
                    .bind("payStrategy", entity.getPayStrategy())
                    .bind("status", entity.getStatus())
                    .bind("amount", entity.getAmount())
                    .bind("paidAt", entity.getPaidAt());

            if (exists) {
                update.bind("id", entity.getId());
            }

            int affectedRows = update.execute();

            return affectedRows > 0 ? entity : null;
        });
    }

    @Override
    public boolean deleteById(Integer integer) {
        jdbi.withHandle(handle -> handle.createUpdate("DELETE FROM payments WHERE id = :id")
                .bind("id", integer)
                .execute() > 0);
        return false;
    }

    public List<Payment> findPendingVnPayPayments(int hoursThreshold) {
        return jdbi.withHandle(handle -> handle.createQuery("""
                SELECT id, order_id, pay_strategy, status, amount, paid_at 
                FROM payments 
                WHERE pay_strategy IN ('VNPay', 'MoMo') 
                AND status = 'Pending' 
                AND paid_at <= DATE_SUB(NOW(), INTERVAL :hours HOUR)
                """)
                .bind("hours", hoursThreshold)
                .mapToBean(Payment.class)
                .list());
    }

    public boolean updateStatus(int paymentId, String status) {
        return jdbi.withHandle(handle -> handle.createUpdate(
                "UPDATE payments SET status = :status WHERE id = :id")
                .bind("status", status)
                .bind("id", paymentId)
                .execute() > 0);
    }
    
    public boolean updateStatusByOrderId(int orderId, String status) {
        return jdbi.withHandle(handle -> handle.createUpdate(
                "UPDATE payments SET status = :status WHERE order_id = :orderId")
                .bind("status", status)
                .bind("orderId", orderId)
                .execute() > 0);
    }

    @Override
    public boolean existsById(Integer integer) {
        return findById(integer).isPresent();
    }
}
