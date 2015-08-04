package edu.mit.kc.workloadbalancing.util;

import org.apache.commons.lang.StringUtils;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Calendar;

/**
 * Created by Brian on 3/16/15.
 */
public class WorkloadUtils {

    public static String formatSponsorName(String sponsorName) {
        String formatted = sponsorName.replace("_", " ");
        formatted = StringUtils.join(StringUtils.splitByCharacterTypeCamelCase(formatted),' ');

        return formatted;
    }

    public static Timestamp translateTimeToDate(Timestamp date, String time) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        String[] timeStrings = time.split(":");
        cal.set(Calendar.HOUR_OF_DAY, Integer.valueOf(timeStrings[0]));
        cal.set(Calendar.MINUTE, Integer.valueOf(timeStrings[1].substring(0, 2)));
        if (timeStrings[1].substring(2).equals("AM")) {
            cal.set(Calendar.AM_PM, Calendar.AM);
        } else {
            cal.set(Calendar.AM_PM, Calendar.PM);
        }

        return new Timestamp(cal.getTimeInMillis());
    }

    public static String translateDateToTimeKey(Timestamp date) {
        SimpleDateFormat hourFormat = new SimpleDateFormat("hh:mma");
        return hourFormat.format(date);
    }
}
