package com.bigdata.flink.model;

import java.io.Serializable;

public class DimSeller implements Serializable {
    private Integer sellerId;
    private String firstName;
    private String lastName;
    private String email;
    private String country;
    private String postalCode;

    public DimSeller() {}

    public DimSeller(Integer sellerId, String firstName, String lastName,
                     String email, String country, String postalCode) {
        this.sellerId = sellerId;
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.country = country;
        this.postalCode = postalCode;
    }

    public Integer getSellerId() { return sellerId; }
    public String getFirstName() { return firstName; }
    public String getLastName() { return lastName; }
    public String getEmail() { return email; }
    public String getCountry() { return country; }
    public String getPostalCode() { return postalCode; }

    public void setSellerId(Integer sellerId) { this.sellerId = sellerId; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    public void setEmail(String email) { this.email = email; }
    public void setCountry(String country) { this.country = country; }
    public void setPostalCode(String postalCode) { this.postalCode = postalCode; }
}
