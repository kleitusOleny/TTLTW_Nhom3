package dao;

import model.Ward;
import java.util.List;
import java.util.Optional;

public class WardDAO extends ADAO implements IDAO<Ward, String> {

    @Override
    public List<Ward> findAll() {
        return jdbi.withHandle(handle ->
            handle.createQuery("SELECT id, ward_code, ward_name, province_id, district_id FROM wards ORDER BY ward_name ASC")
                .mapToBean(Ward.class)
                .list()
        );
    }

    public List<Ward> findByProvinceAndDistrict(String provinceId, String districtId) {
        return jdbi.withHandle(handle ->
            handle.createQuery("SELECT id, ward_code, ward_name, province_id, district_id FROM wards WHERE province_id = :provinceId AND district_id = :districtId ORDER BY ward_name ASC")
                .bind("provinceId", provinceId)
                .bind("districtId", districtId)
                .mapToBean(Ward.class)
                .list()
        );
    }

    public List<Ward> findByNames(String provinceName, String districtName) {
        return jdbi.withHandle(handle ->
            handle.createQuery("SELECT w.id, w.ward_code, w.ward_name, w.province_id, w.district_id " +
                             "FROM wards w " +
                             "JOIN districts d ON w.district_id = d.id " +
                             "JOIN provinces p ON d.province_id = p.id " +
                             "WHERE p.province_name = :provinceName AND d.district_name = :districtName " +
                             "ORDER BY w.ward_name ASC")
                .bind("provinceName", provinceName)
                .bind("districtName", districtName)
                .mapToBean(Ward.class)
                .list()
        );
    }

    public List<Ward> findByDistrictId(String districtId) {
        return jdbi.withHandle(handle ->
            handle.createQuery("SELECT id, ward_code, ward_name, province_id, district_id FROM wards WHERE district_id = :districtId ORDER BY ward_name ASC")
                .bind("districtId", districtId)
                .mapToBean(Ward.class)
                .list()
        );
    }

    @Override
    public Optional<Ward> findById(String id) {
        return jdbi.withHandle(handle ->
            handle.createQuery("SELECT id, ward_code, ward_name, province_id, district_id FROM wards WHERE id = :id")
                .bind("id", id)
                .mapToBean(Ward.class)
                .findFirst()
        );
    }

    @Override
    public Ward save(Ward entity) {
        jdbi.useHandle(handle ->
            handle.createUpdate("INSERT INTO wards (id, ward_code, ward_name, province_id, district_id) " +
                                "VALUES (:id, :ward_code, :ward_name, :province_id, :district_id) " +
                                "ON DUPLICATE KEY UPDATE ward_code = :ward_code, ward_name = :ward_name, " +
                                "province_id = :province_id, district_id = :district_id")
                .bindBean(entity)
                .execute()
        );
        return entity;
    }

    @Override
    public boolean deleteById(String id) {
        return jdbi.withHandle(handle ->
            handle.createUpdate("DELETE FROM wards WHERE id = :id")
                .bind("id", id)
                .execute() > 0
        );
    }

    @Override
    public boolean existsById(String id) {
        return findById(id).isPresent();
    }
}
