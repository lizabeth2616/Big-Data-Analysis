package com.bigdata.flink.model;

import java.io.Serializable;

public class DimCustomer implements Serializable {
    private Integer customerId;
    private String firstName;
    private String lastName;
    private Integer age;
    private String email;
    private String country;
    private String postalCode;
    private String petType;
    private String petName;
    private String petBreed;

    public DimCustomer() {}

    public DimCustomer(Integer customerId, String firstName, String lastName, Integer age,
                       String email, String country, String postalCode, String petType,
                       String petName, String petBreed) {
        this.customerId = customerId;
        this.firstName = firstName;
        this.lastName = lastName;
        this.age = age;
        this.email = email;
        this.country = country;
        this.postalCode = postalCode;
        this.petType = petType;
        this.petName = petName;
        this.petBreed = petBreed;
    }

    public Integer getCustomerId() { return customerId; }
    public String getFirstName() { return firstName; }
    public String getLastName() { return lastName; }
    public Integer getAge() { return age; }
    public String getEmail() { return email; }
    public String getCountry() { return country; }
    public String getPostalCode() { return postalCode; }
    public String getPetType() { return petType; }
    public String getPetName() { return petName; }
    public String getPetBreed() { return petBreed; }

    public void setCustomerId(Integer customerId) { this.customerId = customerId; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    public void setAge(Integer age) { this.age = age; }
    public void setEmail(String email) { this.email = email; }
    public void setCountry(String country) { this.country = country; }
    public void setPostalCode(String postalCode) { this.postalCode = postalCode; }
    public void setPetType(String petType) { this.petType = petType; }
    public void setPetName(String petName) { this.petName = petName; }
    public void setPetBreed(String petBreed) { this.petBreed = petBreed; }
}
