package com.bigdata.flink.model;

import java.io.Serializable;
import java.sql.Date;

public class DimDate implements Serializable {
    private Date dateKey;
    private Integer yearNum;
    private Integer monthNum;
    private Integer dayNum;

    public DimDate() {}

    public DimDate(Date dateKey, Integer yearNum, Integer monthNum, Integer dayNum) {
        this.dateKey = dateKey;
        this.yearNum = yearNum;
        this.monthNum = monthNum;
        this.dayNum = dayNum;
    }

    public Date getDateKey() { return dateKey; }
    public Integer getYearNum() { return yearNum; }
    public Integer getMonthNum() { return monthNum; }
    public Integer getDayNum() { return dayNum; }

    public void setDateKey(Date dateKey) { this.dateKey = dateKey; }
    public void setYearNum(Integer yearNum) { this.yearNum = yearNum; }
    public void setMonthNum(Integer monthNum) { this.monthNum = monthNum; }
    public void setDayNum(Integer dayNum) { this.dayNum = dayNum; }
}
