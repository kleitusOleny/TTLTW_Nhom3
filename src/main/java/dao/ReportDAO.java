package dao;

import java.util.List;
import java.util.Map;

public class ReportDAO extends ADAO {

    public List<Map<String, Object>> getRevenueByDay() {
        return jdbi.withHandle(handle ->
                handle.createQuery("SELECT CONCAT(DATE(create_at), '') as time_label, SUM(total_price) as revenue " +
                                "FROM orders " +
                                "WHERE is_delete IS NULL AND create_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) " +
                                "GROUP BY CONCAT(DATE(create_at), '') " +
                                "ORDER BY CONCAT(DATE(create_at), '') ASC")
                        .mapToMap()
                        .list()
        );
    }
    public List<Map<String, Object>> getRevenueByMonth() {
        return jdbi.withHandle(handle ->
                handle.createQuery("SELECT DATE_FORMAT(create_at, '%Y-%m') as time_label, SUM(total_price) as revenue " +
                                "FROM orders " +
                                "WHERE is_delete IS NULL AND create_at >= DATE_SUB(NOW(), INTERVAL 12 MONTH) " +
                                "GROUP BY DATE_FORMAT(create_at, '%Y-%m') " +
                                "ORDER BY DATE_FORMAT(create_at, '%Y-%m') ASC")
                        .mapToMap()
                        .list()
        );
    }

    public List<Map<String, Object>> getRevenueByQuarter() {
        return jdbi.withHandle(handle ->
                handle.createQuery("SELECT CONCAT(YEAR(create_at), '-Q', QUARTER(create_at)) as time_label, SUM(total_price) as revenue " +
                                "FROM orders " +
                                "WHERE is_delete IS NULL AND create_at >= DATE_SUB(NOW(), INTERVAL 24 MONTH) " +
                                "GROUP BY CONCAT(YEAR(create_at), '-Q', QUARTER(create_at)) " +
                                "ORDER BY CONCAT(YEAR(create_at), '-Q', QUARTER(create_at)) ASC")
                        .mapToMap()
                        .list()
        );
    }

    public List<Map<String, Object>> getRevenueByYear() {
        return jdbi.withHandle(handle ->
                handle.createQuery("SELECT CONCAT(YEAR(create_at), '') as time_label, SUM(total_price) as revenue " +
                                "FROM orders " +
                                "WHERE is_delete IS NULL " +
                                "GROUP BY CONCAT(YEAR(create_at), '') " +
                                "ORDER BY CONCAT(YEAR(create_at), '') ASC")
                        .mapToMap()
                        .list()
        );
    }

    public List<Map<String, Object>> getBestSellingProducts(int limit) {
        return getBestSellingProducts(limit, null, null);
    }

    public List<Map<String, Object>> getBestSellingProducts(int limit, String startDate, String endDate) {
        return jdbi.withHandle(handle -> {
            String sql = "SELECT p.id, p.product_name as product_name, SUM(oi.quantity) as total_sold, SUM(oi.quantity * oi.unit_price) as total_revenue " +
                         "FROM order_items oi " +
                         "JOIN orders o ON oi.order_id = o.id " +
                         "JOIN products p ON oi.product_id = p.id " +
                         "WHERE o.is_delete IS NULL ";
            
            if (startDate != null && !startDate.trim().isEmpty()) {
                sql += "AND o.create_at >= :startDate ";
            }
            if (endDate != null && !endDate.trim().isEmpty()) {
                sql += "AND o.create_at <= :endDate ";
            }
            
            sql += "GROUP BY p.id, p.product_name " +
                   "ORDER BY total_sold DESC " +
                   "LIMIT :limit";
                   
            var query = handle.createQuery(sql).bind("limit", limit);
            
            if (startDate != null && !startDate.trim().isEmpty()) {
                query = query.bind("startDate", startDate + " 00:00:00");
            }
            if (endDate != null && !endDate.trim().isEmpty()) {
                query = query.bind("endDate", endDate + " 23:59:59");
            }
            
            return query.mapToMap().list();
        });
    }

    public List<Map<String, Object>> getUnsoldProducts(int months) {
        return jdbi.withHandle(handle ->
                handle.createQuery("SELECT p.id, p.product_name, p.price, p.quantity " +
                                "FROM products p " +
                                "WHERE p.is_delete = 0 " +
                                "  AND p.id NOT IN ( " +
                                "      SELECT DISTINCT oi.product_id " +
                                "      FROM order_items oi " +
                                "      JOIN orders o ON oi.order_id = o.id " +
                                "      WHERE o.is_delete IS NULL AND o.create_at >= DATE_SUB(NOW(), INTERVAL :months MONTH) " +
                                "  ) " +
                                "ORDER BY p.product_name ASC")
                        .bind("months", months)
                        .mapToMap()
                        .list()
        );
    }

    public List<Map<String, Object>> getCustomerOrderStats(String period) {
        String timeCondition = "";
        if ("this_month".equals(period)) {
            timeCondition = " AND YEAR(o.create_at) = YEAR(NOW()) AND MONTH(o.create_at) = MONTH(NOW())";
        } else if ("this_quarter".equals(period)) {
            timeCondition = " AND YEAR(o.create_at) = YEAR(NOW()) AND QUARTER(o.create_at) = QUARTER(NOW())";
        }

        final String sql = "SELECT u.id, u.email, u.username, u.full_name, u.phone_number, u.created_at, " +
                "COUNT(DISTINCT o.id) as total_orders, " +
                "COALESCE(SUM(o.total_price), 0) as total_spend, " +
                "COALESCE(all_time.total_orders, 0) as all_time_orders, " +
                "COALESCE(all_time.total_spend, 0) as all_time_spend, " +
                "(SELECT COUNT(*) FROM evaluates WHERE user_id = u.id) as total_reviews " +
                "FROM users u " +
                "LEFT JOIN orders o ON u.id = o.user_id AND o.is_delete IS NULL" + timeCondition + " " +
                "LEFT JOIN ( " +
                "    SELECT user_id, COUNT(id) as total_orders, SUM(total_price) as total_spend " +
                "    FROM orders " +
                "    WHERE is_delete IS NULL " +
                "    GROUP BY user_id " +
                ") all_time ON u.id = all_time.user_id " +
                "GROUP BY u.id, u.email, u.username, u.full_name, u.phone_number, u.created_at, all_time.total_orders, all_time.total_spend " +
                "ORDER BY total_spend DESC";

        return jdbi.withHandle(handle ->
                handle.createQuery(sql)
                        .mapToMap()
                        .list()
        );
    }

    public Map<String, Object> getCustomerStatsSummary() {
        final String sql = "SELECT " +
                "SUM(CASE WHEN all_time_orders >= 5 OR all_time_spend >= 5000000 THEN 1 ELSE 0 END) as loyal_count, " +
                "SUM(CASE WHEN all_time_orders > 0 AND all_time_orders < 5 AND all_time_spend < 5000000 THEN 1 ELSE 0 END) as new_count, " +
                "SUM(CASE WHEN all_time_orders = 0 OR all_time_orders IS NULL THEN 1 ELSE 0 END) as potential_count " +
                "FROM ( " +
                "    SELECT u.id, " +
                "           COUNT(o.id) as all_time_orders, " +
                "           SUM(o.total_price) as all_time_spend " +
                "    FROM users u " +
                "    LEFT JOIN orders o ON u.id = o.user_id AND o.is_delete IS NULL " +
                "    GROUP BY u.id " +
                ") as customer_base";

        return jdbi.withHandle(handle ->
                handle.createQuery(sql)
                        .mapToMap()
                        .findOne()
                        .orElse(Map.of("loyal_count", 0, "new_count", 0, "potential_count", 0))
        );
    }
    public List<Map<String, Object>> getOrderStatusStats(String period) {
        String timeCondition = "";
        if ("this_month".equals(period)) {
            timeCondition = " AND YEAR(o.create_at) = YEAR(NOW()) AND MONTH(o.create_at) = MONTH(NOW())";
        } else if ("this_quarter".equals(period)) {
            timeCondition = " AND YEAR(o.create_at) = YEAR(NOW()) AND QUARTER(o.create_at) = QUARTER(NOW())";
        }

        final String sql = "SELECT COALESCE(so.status, 'Chưa xác định') as status, COUNT(o.id) as order_count " +
                           "FROM orders o " +
                           "LEFT JOIN ship_orders so ON o.id = so.order_id " +
                           "WHERE o.is_delete IS NULL" + timeCondition + " " +
                           "GROUP BY so.status " +
                           "ORDER BY order_count DESC";
                           
        return jdbi.withHandle(handle ->
                handle.createQuery(sql)
                        .mapToMap()
                        .list()
        );
    }
    public Map<String, Object> getPaymentStatusSummary(String period) {
        String timeCondition = "";
        if ("this_month".equals(period)) {
            timeCondition = " AND YEAR(o.create_at) = YEAR(NOW()) AND MONTH(o.create_at) = MONTH(NOW())";
        } else if ("this_quarter".equals(period)) {
            timeCondition = " AND YEAR(o.create_at) = YEAR(NOW()) AND QUARTER(o.create_at) = QUARTER(NOW())";
        }

        final String sql = "SELECT " +
            "COALESCE(SUM(CASE WHEN p.status IN ('Success', 'Đã thanh toán', 'Completed') THEN p.amount ELSE 0 END), 0) as total_collected, " +
            "COALESCE(SUM(CASE WHEN p.status IN ('Pending', 'Chưa thanh toán', 'Failed') THEN p.amount ELSE 0 END), 0) as total_owed " +
            "FROM payments p " +
            "JOIN orders o ON p.order_id = o.id " +
            "WHERE o.is_delete IS NULL" + timeCondition;

        return jdbi.withHandle(handle ->
                handle.createQuery(sql)
                        .mapToMap()
                        .findOne()
                        .orElse(Map.of("total_collected", 0, "total_owed", 0))
        );
    }
    public List<Map<String, Object>> getPaymentMethodStats(String period) {
        String timeCondition = "";
        if ("this_month".equals(period)) {
            timeCondition = " AND YEAR(o.create_at) = YEAR(NOW()) AND MONTH(o.create_at) = MONTH(NOW())";
        } else if ("this_quarter".equals(period)) {
            timeCondition = " AND YEAR(o.create_at) = YEAR(NOW()) AND QUARTER(o.create_at) = QUARTER(NOW())";
        }

        final String sql = "SELECT COALESCE(p.pay_strategy, 'Khác') as method, COUNT(p.id) as count, COALESCE(SUM(p.amount), 0) as total_amount " +
                           "FROM payments p " +
                           "JOIN orders o ON p.order_id = o.id " +
                           "WHERE o.is_delete IS NULL" + timeCondition + " " +
                           "GROUP BY p.pay_strategy " +
                           "ORDER BY total_amount DESC";
                           
        return jdbi.withHandle(handle ->
                handle.createQuery(sql)
                        .mapToMap()
                        .list()
        );
    }

    public List<Map<String, Object>> getDeliveredButUnpaidOrders(String period) {
        String timeCondition = "";
        if ("this_month".equals(period)) {
            timeCondition = " AND YEAR(o.create_at) = YEAR(NOW()) AND MONTH(o.create_at) = MONTH(NOW())";
        } else if ("this_quarter".equals(period)) {
            timeCondition = " AND YEAR(o.create_at) = YEAR(NOW()) AND QUARTER(o.create_at) = QUARTER(NOW())";
        }

        final String sql = "SELECT o.id, u.full_name, u.email, o.total_price, p.pay_strategy, so.status as ship_status " +
                           "FROM orders o " +
                           "JOIN users u ON o.user_id = u.id " +
                           "JOIN ship_orders so ON o.id = so.order_id " +
                           "JOIN payments p ON o.id = p.order_id " +
                           "WHERE o.is_delete IS NULL " +
                           "AND so.status IN ('Đã giao', 'Giao hàng thành công') " +
                           "AND p.status IN ('Pending', 'Chưa thanh toán', 'Failed')" + timeCondition + " " +
                           "ORDER BY o.create_at DESC";

        return jdbi.withHandle(handle ->
                handle.createQuery(sql)
                        .mapToMap()
                        .list()
        );
    }
    public List<Map<String, Object>> getPromotionalProductStats(String period) {
        String timeCondition = "";
        if ("this_month".equals(period)) {
            timeCondition = " AND YEAR(o.create_at) = YEAR(NOW()) AND MONTH(o.create_at) = MONTH(NOW())";
        } else if ("this_quarter".equals(period)) {
            timeCondition = " AND YEAR(o.create_at) = YEAR(NOW()) AND QUARTER(o.create_at) = QUARTER(NOW())";
        }

        final String sql = "SELECT p.id as product_id, p.product_name, p.price as original_price, " +
                           "d.id as discount_id, d.discount_code, d.discount_type, d.discount_value, " +
                           "d.discount_from, d.discount_to, " +
                           "CASE " +
                           "    WHEN d.discount_type = '%' OR d.discount_type = 'PERCENT' THEN p.price * (1 - d.discount_value / 100.0) " +
                           "    WHEN d.discount_type = 'VND' OR d.discount_type = 'AMOUNT' THEN GREATEST(p.price - d.discount_value, 0) " +
                           "    ELSE p.price " +
                           "END as discounted_price, " +
                           "COALESCE(SUM(oi.quantity), 0) as total_sold, " +
                           "COALESCE(SUM(oi.quantity * oi.unit_price), 0) as total_revenue " +
                           "FROM products p " +
                           "JOIN dis_process dp ON p.id = dp.product_id " +
                           "JOIN discounts d ON dp.discount_id = d.id " +
                           "LEFT JOIN order_items oi ON p.id = oi.product_id " +
                           "LEFT JOIN orders o ON oi.order_id = o.id AND o.is_delete IS NULL" + timeCondition + " AND o.create_at BETWEEN d.discount_from AND d.discount_to " +
                           "WHERE p.is_delete = 0 " +
                           "AND dp.is_delete = 0 " +
                           "AND d.is_delete = 0 " +
                           "AND d.is_active = 1 " +
                           "AND NOW() BETWEEN d.discount_from AND d.discount_to " +
                           "GROUP BY p.id, p.product_name, p.price, d.id, d.discount_code, d.discount_type, d.discount_value, d.discount_from, d.discount_to " +
                           "ORDER BY total_sold DESC, total_revenue DESC";

        return jdbi.withHandle(handle ->
                handle.createQuery(sql)
                        .mapToMap()
                        .list()
        );
    }
    public List<Map<String, Object>> getActivePromotionStats(String timeFilter) {
        String filterCondition = "";
        if ("expiring_24h".equals(timeFilter)) {
            filterCondition = " AND d.discount_to <= DATE_ADD(NOW(), INTERVAL 24 HOUR) ";
        } else if ("expiring_3days".equals(timeFilter)) {
            filterCondition = " AND d.discount_to <= DATE_ADD(NOW(), INTERVAL 3 DAY) ";
        }

        final String sql = "SELECT d.id as discount_id, d.discount_code, d.discount_type, " +
                           "d.discount_value, d.apply_type, " +
                           "DATE_FORMAT(d.discount_from, '%d/%m/%Y %H:%i') as discount_from_str, " +
                           "DATE_FORMAT(d.discount_to, '%d/%m/%Y %H:%i') as discount_to_str, " +
                           "d.quantity as remaining_quantity, " +
                           "(SELECT COUNT(*) FROM orders o WHERE o.is_delete IS NULL AND " +
                           "(o.discount_id = d.id OR o.shipping_discount_id = d.id OR o.voucher_discount_id = d.id OR o.loyalty_discount_id = d.id)) as used_quantity " +
                           "FROM discounts d " +
                           "WHERE d.is_active = 1 " +
                           "AND d.is_delete = 0 " +
                           "AND d.discount_to >= NOW() " +
                           filterCondition +
                           "ORDER BY d.discount_to ASC";

        return jdbi.withHandle(handle ->
                handle.createQuery(sql)
                        .mapToMap()
                        .list()
        );
    }
}
