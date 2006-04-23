<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_config/deployConfig.cfm,v 1.12 2004/08/11 03:13:23 brendan Exp $
$Author: brendan $
$Date: 2004/08/11 03:13:23 $
$Name: milestone_2-3-2 $
$Revision: 1.12 $

|| DESCRIPTION || 
$Description: deploys all config files $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfset stStatus = StructNew()>
<cfset stStatus.msg = "Table deployed successfully">
<cftry>
	<cfswitch expression="#application.dbtype#">
	<cfcase value="ora">
		<cfif arguments.bDropTable>
			<cfquery datasource="#arguments.dsn#" name="qExists">
				SELECT * FROM USER_TABLES WHERE TABLE_NAME = 'CONFIG'
			</cfquery>
			<cfif qExists.recordCount>
			<cfquery datasource="#arguments.dsn#" name="dropConfig">
				DROP TABLE #application.dbowner#config
			</cfquery>
			</cfif>	
		</cfif>
		<cfquery datasource="#arguments.dsn#" name="createConfig">
			CREATE TABLE #application.dbowner#config
				(
				CONFIGNAME VARCHAR2(50) NOT NULL,
				WCONFIG CLOB NULL,
				CONSTRAINT PK_CONFIG PRIMARY KEY (CONFIGNAME)
				) 
		</cfquery>
	</cfcase>
	<cfcase value="mysql">
		<cfif arguments.bDropTable>
			<cfquery datasource="#arguments.dsn#" name="dropConfig">			
				DROP TABLE IF EXISTS #application.dbowner#config			
			</cfquery>
		</cfif>
		<cfquery datasource="#arguments.dsn#" name="createConfig">
			CREATE TABLE #application.dbowner#config
				(
				configName varchar(50) NOT NULL,
				wConfig text NULL,
				PRIMARY KEY (configName)
				) 
		</cfquery>
	</cfcase>
	<cfcase value="postgresql">
		<cfif arguments.bDropTable>
			<cftry><cfquery datasource="#arguments.dsn#" name="dropConfig">			
				DROP TABLE #application.dbowner#config			
			</cfquery><cfcatch></cfcatch></cftry>
		</cfif>
		<cfquery datasource="#arguments.dsn#" name="createConfig">
			CREATE TABLE #application.dbowner#config
				(
				configName varchar(50) NOT NULL PRIMARY KEY,
				wConfig text NULL
				) 
		</cfquery>
	</cfcase>
	<cfdefaultcase>
		<cfif arguments.bDropTable>
			<cfquery datasource="#arguments.dsn#" name="dropConfig">
			if exists (select * from sysobjects where name = '#application.dbowner#config')
			DROP TABLE dbo.config
		
			-- return recordset to stop CF bombing out?!?
			select count(*) as blah from sysobjects
			</cfquery>
		</cfif>
		<cfquery datasource="#arguments.dsn#" name="createConfig">
			CREATE TABLE #application.dbowner#config
				(
				configName char(50) NOT NULL,
				wConfig ntext NULL
				) ON [PRIMARY]
				 TEXTIMAGE_ON [PRIMARY];
			
			ALTER TABLE #application.dbowner#config ADD CONSTRAINT
				PK_config PRIMARY KEY NONCLUSTERED 
				(
				configName
				) ON [PRIMARY];
		</cfquery>
	</cfdefaultcase>
	</cfswitch>
	<cfcatch>
		<cfset stStatus.bSuccess = "false">
		<cfset stStatus.message = cfcatch.message>
		<cfset stStatus.detail = cfcatch.detail>
	</cfcatch>
</cftry>
<cfset stStatus.bSuccess = "true">