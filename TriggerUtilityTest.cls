/**
 * @description Test class of the TriggerUtility.cls
 *
 * @author Borislav Borisov, https://github.com/borislavsfdc/TriggerUtility/
 * @date June 4, 2019
 * @version 1.0
 */
@isTest
public class TriggerUtilityTest
{   
    @isTest static void testGetFieldValues()
    {
        Account account = new Account(Name = 'Company AG');
        insert account;
        
    	List<Account> newList = new List<Account>();
        newList.add(new Account(Name = 'Company New AG'));
        
        Map<Id, Account> oldMap = new Map<Id, Account>();
        oldMap.put(account.Id, account);
        
        Set<Object> fieldValues = TriggerUtility.getFieldValues(newList, oldMap, 'Name');
        System.assertEquals(1, fieldValues.size());
        System.assertEquals('Company New AG', (String)new List<Object>(fieldValues).get(0));
	}
    
    @isTest static void testMapToRelatedField()
    {
		List<Account> newList = new List<Account>();
        newList.add(new Account(Name = 'Company Bonn South AG', BillingCity = 'Bonn'));
        newList.add(new Account(Name = 'Company Hamburg AG', BillingCity = 'Hamburg'));
        newList.add(new Account(Name = 'Company Bonn West AG', BillingCity = 'Bonn'));
        
        Map<Object, sObject> cityMap = TriggerUtility.mapToRelatedField(newList, 'BillingCity');
        System.assertEquals(2, cityMap.size());
        System.assertEquals('Company Bonn West AG', cityMap.get('Bonn').get('Name'));
        System.assertEquals('Company Hamburg AG', cityMap.get('Hamburg').get('Name'));
	}
    
    @isTest static void testGetModifiedObjects()
    {
    	Account account = new Account(Name = 'Company AG', BillingCity = 'Bonn');
        insert account;
        
    	List<Account> newList = new List<Account>();
        newList.add(account);
        
        Account modifiedAccount = [SELECT Name, BillingCity FROM Account WHERE Id = :account.Id];
        modifiedAccount.Name = 'Company Old AG';
        
        Map<Id, Account> oldMap = new Map<Id, Account>();
        oldMap.put(modifiedAccount.Id, modifiedAccount);
        
        Set<sObject> modifiedName =  TriggerUtility.getModifiedObjects (new Set<String>{'Name'}, newList, oldMap);
        System.assertEquals(1, modifiedName.size());
        
        Set<sObject> modifiedBillingCity =  TriggerUtility.getModifiedObjects (new Set<String>{'BillingCity'}, newList, oldMap);
        System.assertEquals(0, modifiedBillingCity.size());
    }
}
