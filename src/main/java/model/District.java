package model;

import org.jdbi.v3.core.mapper.reflect.ColumnName;

public class District {
    @ColumnName("id")
    private String id;
    @ColumnName("province_id")
    private String provinceId;
    @ColumnName("code")
    private String code;
    @ColumnName("district_name")
    private String districtName;
    @ColumnName("support_type")
    private String supportType;
    @ColumnName("type")
    private String type;

    public District() {}

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getProvinceId() {
        return provinceId;
    }

    public void setProvinceId(String provinceId) {
        this.provinceId = provinceId;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getDistrictName() {
        return districtName;
    }

    public void setDistrictName(String districtName) {
        this.districtName = districtName;
    }

    public String getSupportType() {
        return supportType;
    }

    public void setSupportType(String supportType) {
        this.supportType = supportType;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }
}
