<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: UD Login Select --->
<!--- @@description: Creates a select list so that users can log into the supported user directories --->

<cfif thistag.ExecutionMode eq "Start">
	<cfif listlen(application.security.getAllUD()) GT 1>
		<cfoutput><fieldset class="formSection"></cfoutput>
		
		<cfoutput><select id="selectuserdirectories" onchange="window.location='#application.url.farcry#/login.cfm?returnUrl=#urlencodedformat(url.returnUrl)#&ud='+this.value;"></cfoutput>
		
		<cfloop list="#application.security.getAllUD()#" index="thisud">
			<cfoutput>
				<option value="#thisud#"<cfif url.ud eq thisud> selected</cfif>>#application.security.userdirectories[thisud].title#</option>
			</cfoutput>
		</cfloop>
		
		<cfoutput></select></cfoutput>
		
		<cfoutput></fieldset></cfoutput>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false" />