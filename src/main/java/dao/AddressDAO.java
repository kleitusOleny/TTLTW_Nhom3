package dao;

import model.Address;

import java.util.List;
import java.util.Optional;

public class AddressDAO extends ADAO implements IDAO<Address,Integer> {
//    @Override
//    public List<Address> getAll() {
//        return jdbi.withHandle(handle -> {
//            return handle.createQuery("select * from addresses where is_delete = 0").mapToBean(Address.class).list();
//        });
//    }
//
//    @Override
//    public Address findById(Address address) {
//        return jdbi.withHandle(handle -> {
//            return handle.createQuery(
//                    "select id, user_id, full_name, phone_number, address_line, city, ward, is_default from addresses where user_id = :user_id AND id = :id")
//                    .bind("user_id", address.getUserId())
//                    .bind("id", address.getId())
//                    .mapToBean(Address.class)
//                    .findOnly();
//        });
//    }
//
//    @Override
//    public boolean create(Address entity) {
//        return jdbi.withHandle(handle -> handle
//                .createUpdate(
//                        """
//                                INSERT INTO addresses (user_id, full_name, phone_number, city, ward, address_line)
//                                VALUES (:user_id, :full_name, :phone_number, :city, :ward, :address_line)
//                                """)
//                .bind("user_id", entity.getUserId())
//                .bind("full_name", entity.getFullName())
//                .bind("phone_number", entity.getPhoneNumber())
//                .bind("city", entity.getCity())
//                .bind("ward", entity.getWard())
//                .bind("address_line", entity.getAddressLine())
//                .execute() > 0);
//    }
//
//    @Override
//    public boolean update(Address entity) {
//        return jdbi.withHandle(handle -> handle.createUpdate("""
//                 UPDATE addresses
//                 SET full_name = :full_name,
//                     phone_number = :phone_number,
//                     city = :city,
//                     ward = :ward,
//                     address_line = :address_line
//                 WHERE user_id = :user_id AND id = :id
//                """)
//                .bind("user_id", entity.getUserId())
//                .bind("id", entity.getId())
//                .bind("full_name", entity.getFullName())
//                .bind("phone_number", entity.getPhoneNumber())
//                .bind("city", entity.getCity())
//                .bind("ward", entity.getWard())
//                .bind("address_line", entity.getAddressLine())
//                .execute() > 0);
//    }
//
//    @Override
//    public boolean delete(Address address) {
//        return jdbi.withHandle(handle -> handle.createUpdate("""
//                 DELETE FROM addresses
//                 WHERE user_id = :user_id AND id = :id
//                """)
//                .bind("user_id", address.getUserId())
//                .bind("id", address.getId())
//                .execute() > 0);
//    }
//
//    @Override
//    public List<Address> search(String keyword) {
//        return null;
//    }
//
//    @Override
//    public boolean exists(Address entity) {
//        return jdbi.withHandle(handle -> handle.createQuery("""
//                    SELECT 1
//                    FROM addresses
//                    WHERE user_id = :user_id
//                      AND address_line = :address_line
//                """)
//                .bind("user_id", entity.getUserId())
//                .bind("address_line", entity.getAddressLine())
//                .mapTo(Integer.class)
//                .findFirst()
//                .isPresent());
//    }
//
//    public List<Address> getByUserID(int id) {
//        return jdbi.withHandle(handle -> {
//            return handle.createQuery(
//                    "select id, user_id, full_name, phone_number, address_line, city, ward, is_default from addresses where user_id = :user_id")
//                    .bind("user_id", id)
//                    .mapToBean(Address.class)
//                    .list();
//        });
//    }

    public void setDefault(Address address) {
        address.setDefault(true);
        jdbi.withHandle(handle -> handle.createUpdate("""
                 UPDATE addresses
                 SET is_default = :is_default
                 WHERE user_id = :user_id AND id = :id
                """)
                .bind("user_id", address.getUserId())
                .bind("id", address.getId())
                .bind("is_default", address.isDefault())
                .execute());
    }

    public void unsetAllDefaults(int userId) {
        jdbi.withHandle(handle -> handle.createUpdate("""
                 UPDATE addresses
                 SET is_default = false
                 WHERE user_id = :user_id
                """)
                .bind("user_id", userId)
                .execute());
    }

    public Address getById(int id) {
        return jdbi.withHandle(handle -> handle.createQuery(
                "select id, user_id, full_name, phone_number, address_line, city, ward, is_default from addresses where id = :id")
                .bind("id", id)
                .mapToBean(Address.class)
                .findFirst().orElse(null));
    }

    @Override
    public List<Address> findAll() {
        return List.of();
    }

    @Override
    public Optional<Address> findById(Integer integer) {
        return Optional.empty();
    }

    @Override
    public Address save(Address entity) {
        return null;
    }

    @Override
    public void deleteById(Integer integer) {

    }

    @Override
    public boolean existsById(Integer integer) {
        return false;
    }
}
