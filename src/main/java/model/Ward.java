package model;

import org.jdbi.v3.core.mapper.reflect.ColumnName;

public class Ward {
    @ColumnName("id")
    private int id;
    @ColumnName("ward_code")
    private String wardCode;
    @ColumnName("ward_name")
    private String wardName;
    @ColumnName("province_id")
    private int provinceId;
    @ColumnName("district_id")
    private int districtId;

    public Ward() {}

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getWardCode() {
        return wardCode;
    }

    public void setWardCode(String wardCode) {
        this.wardCode = wardCode;
    }

    public String getWardName() {
        return wardName;
    }

    public void setWardName(String wardName) {
        this.wardName = wardName;
    }

    public int getProvinceId() {
        return provinceId;
    }

    public void setProvinceId(int provinceId) {
        this.provinceId = provinceId;
    }

    public int getDistrictId() {
        return districtId;
    }

    public void setDistrictId(int districtId) {
        this.districtId = districtId;
    }
}
