package dao;

import java.util.List;
import java.util.Map;

public class ReportDAO extends ADAO {

    // 1. Doanh thu theo ngày (30 ngày qua)
    public List<Map<String, Object>> getRevenueByDay() {
        return jdbi.withHandle(handle ->
                handle.createQuery("SELECT CONCAT(DATE(create_at), '') as time_label, SUM(total_price) as revenue " +
                                "FROM orders " +
                                "WHERE is_delete IS NULL AND create_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) " +
                                "GROUP BY DATE(create_at) " +
                                "ORDER BY DATE(create_at) ASC")
                        .mapToMap()
                        .list()
        );
    }

    // 2. Doanh thu theo tháng (12 tháng qua)
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

    // 3. Doanh thu theo quý (8 quý qua)
    public List<Map<String, Object>> getRevenueByQuarter() {
        return jdbi.withHandle(handle ->
                handle.createQuery("SELECT CONCAT(YEAR(create_at), '-Q', QUARTER(create_at)) as time_label, SUM(total_price) as revenue " +
                                "FROM orders " +
                                "WHERE is_delete IS NULL AND create_at >= DATE_SUB(NOW(), INTERVAL 24 MONTH) " +
                                "GROUP BY YEAR(create_at), QUARTER(create_at) " +
                                "ORDER BY YEAR(create_at) ASC, QUARTER(create_at) ASC")
                        .mapToMap()
                        .list()
        );
    }

    // 4. Doanh thu theo năm (tất cả các năm)
    public List<Map<String, Object>> getRevenueByYear() {
        return jdbi.withHandle(handle ->
                handle.createQuery("SELECT CONCAT(YEAR(create_at), '') as time_label, SUM(total_price) as revenue " +
                                "FROM orders " +
                                "WHERE is_delete IS NULL " +
                                "GROUP BY YEAR(create_at) " +
                                "ORDER BY YEAR(create_at) ASC")
                        .mapToMap()
                        .list()
        );
    }

    // 5. Top 10 sản phẩm bán chạy nhất
    public List<Map<String, Object>> getBestSellingProducts(int limit) {
        return jdbi.withHandle(handle ->
                handle.createQuery("SELECT p.id, p.product_name as product_name, SUM(oi.quantity) as total_sold, SUM(oi.quantity * oi.unit_price) as total_revenue " +
                                "FROM order_items oi " +
                                "JOIN orders o ON oi.order_id = o.id " +
                                "JOIN products p ON oi.product_id = p.id " +
                                "WHERE o.is_delete IS NULL " +
                                "GROUP BY p.id, p.product_name " +
                                "ORDER BY total_sold DESC " +
                                "LIMIT :limit")
                        .bind("limit", limit)
                        .mapToMap()
                        .list()
        );
    }

    // 6. Sản phẩm không bán được trong N tháng qua
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

    // 7. Thống kê chi tiết khách hàng và đơn hàng theo khoảng thời gian
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

    // 8. Thống kê tóm tắt số lượng khách hàng theo phân loại
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
}
