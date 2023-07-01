#To delete a mail sent by error from User A to multiple users in Exchange Online, you can follow these steps:


   Connect-ExchangeOnline -UserPrincipalName admin@contoso.com
   
  

   Get-MessageTrace -SenderAddress userA@contoso.com -StartDate "2023-06-01" -EndDate "2023-06-03"
   
  
   Remove-MessageTrace -MessageTraceId "MessageTraceId"
   
