/**
 * @description This are utility methods for apex triggers. Do not repeat yourself and 
 *              enforce best practices by using this simple patterns in apex.
 *
 * @author Borislav Borisov, https://github.com/borislavsfdc/TriggerUtility/
 * @date June 4, 2019
 * @version 1.0
 */
public class TriggerUtility
{
    /**
    *   Return TRUE if the current execution context is asynchronous.
    */
    public static Boolean isAsynchExecutionContext ()
    {
        return System.isBatch() || System.isFuture() || System.isQueueable() || System.isScheduled();
    }
    
    /**
    *   @description Returns a Set of all values of the field name.
    *
    *   @param newList  List of the new versions of the sObject records.
    *   @param oldMap   Map of the old versions of the sObject records.
    *   @param fieldName    API name of the field
    */
    public static Set<Object> getFieldValues (List<sObject> newList, Map<Id, sObject> oldMap, String fieldName)
    {
        Set<Object> resultSet = new Set<Object>();
        for (sObject record : (newList == null ? oldMap.values() : newList))
        {
            Object value = record.get(fieldName);
            if (value != null)
            {
                resultSet.add(value);
            }
            sObject oldRecord = oldMap == null ? null : oldMap.get(record.Id);
            value = oldRecord == null ? null : oldRecord.get(fieldName);
            if(oldRecord != null && value != null)
            {
                resultSet.add(value);
            }
        }
        return resultSet;
    }
    
    /**
    *   @description Returns a Map of the list of sObjects and use the field name as a Key of the map.
    *
    *   @param newList  List of the new versions of the sObject records.
    *   @param fieldName API name of the field
    */
    public static Map<Object, sObject> mapToRelatedField (List<sObject> newList, String fieldName)
    {
        Map<Object, sObject> resultMap = new Map<Object, sObject>();
        for (sObject record : newList)
        {
            Object value = record.get(fieldName);
            if (value != null)
            {
                resultMap.put(value, record);
            }
        }
        return resultMap;
    }

    /**
    *   @description Returns the input string without special characters.
    *
    *   @param value    Input String
    */  
    public static String replaceSpecialCharacters (String value)
    {
        if(value != null)
        {
            return value.replaceAll('\\n', '').replaceAll('\\b', '').replaceAll('\\f', '').replaceAll('\\r', '').replaceAll('\\t', '').replaceAll('\\"', '').replaceAll('\\\\', '');
        }
        return value;
    }
    
    /**
    *   @description Returns TRUE if Person Account is enabled.
    */  
    public static Boolean isPersonAccountEnabled ()
    {
        return Account.SObjectType.getDescribe().hasSubtypes;
    }
    
    /**
    *   @description Returns generated GUID.
    *   @example: B16751D41A2C9E437
    */
    public static String generateGUID ()
    {
        return EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(1, 18).toUpperCase();
    }

    /**
    *   @description Returns a Set of sObject records which field changes are matching the fields in the fieldsList input parameter.
    *
    *   @param fieldsList   List of field API names
    *   @param newList  List of the new versions of the sObject records.
    *   @param oldMap   Map of the old versions of the sObject records.
    */
    public static Set<sObject> getModifiedObjects (Set<String> fieldsList, List<sObject> newList, Map<Id, sObject> oldMap)
    {
        return getModifiedObjects(fieldsList, newList, oldMap, null);
    }
    
    /**
    *   @description Returns a Set of sObject's which field changes matched the field in the fieldsList input parameter.
    *
    *   @param fieldsList   List of field API names
    *   @param newList  List of the new versions of the sObject records.
    *   @param oldMap   Map of the old versions of the sObject records.
    *   @param recordTypeSet    Set of RecordType Id's
    */
    public static Set<sObject> getModifiedObjects (Set<String> fieldsList, List<sObject> newList, Map<Id, sObject> oldMap, Set<Id> recordTypeSet)
    {
        if(newList == null)
        {
            // On Delete
            return new Set<sObject>();
        }
        Set<sObject> resultSet = new Set<sObject>();
        for (sObject record : newList)
        {
            if (oldMap == null)
            {
                // On Insert
                if( recordTypeSet != null && !recordTypeSet.isEmpty() && 
                    recordTypeSet.contains((Id)record.get('RecordTypeId')))
                {
                    resultSet.add(record);
                }
            }
            else
            {
                // On Update
                sObject oldRecord = oldMap.get(record.Id);
                for (String fieldName: fieldsList)
                {
                    if(recordTypeSet != null && !recordTypeSet.isEmpty())
                    {
                        if (recordTypeSet.contains((Id)record.get('RecordTypeId')) && 
                            record.get(fieldName) != oldRecord.get(fieldName))
                        {
                            resultSet.add(record);
                        }   
                    }
                    else if (record.get(fieldName) != oldRecord.get(fieldName))
                    {
                        resultSet.add(record);
                    }
                }
            }
        }
        return resultSet;
    }
}
