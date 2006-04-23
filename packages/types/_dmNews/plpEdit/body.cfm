<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmNews/plpEdit/body.cfm,v 1.14 2005/01/10 06:42:42 brendan Exp $
$Author: brendan $
$Date: 2005/01/10 06:42:42 $
$Name: milestone_2-3-2 $
$Revision: 1.14 $

|| DESCRIPTION || 
$Description: body step for dmNews plp. Displays text editor with option to toggle to plain html text area. $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->
<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="farcry">

<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>

<!--- check for toggle option --->
<cfif isdefined("form.toggle")>
	<cfset session.toggleTextArea = 1>
<cfelse>
	<cfset session.toggleTextArea = 0>
</cfif>

<!--- work out if onClick event needed for specified rich text editor --->
<cfswitch expression="#application.config.general.richTextEditor#">
	<cfcase value="soEditorPro">
		<cfset onClickEvent = "soEditorbody.updateFormField();">
	</cfcase>
	<cfcase value="soEditor">
		<cfset onClickEvent = "soEditorbody.updateFormField();">
	</cfcase>
	<cfcase value="textArea">
		<cfset onClickEvent = "">
	</cfcase>
	<cfcase value="eopro">
		<cfset onClickEvent= "scriptForm_onsubmit();">
	</cfcase>
	<cfcase value="htmlarea">
		<cfset onClickEvent= "document.editform.onsubmit();document.editform.submit();">
	</cfcase>
	<cfdefaultcase>
		<cfset onClickEvent = "">
	</cfdefaultcase>
</cfswitch>
	
<!--- copy related items to a list for looping --->
<cfset relatedItems = arraytolist(output.aObjectIds)>

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<farcry:plpNavigationMove>


<cfif NOT thisstep.isComplete>
	<cfoutput><form action="#cgi.script_name#?#cgi.query_string#" method="post" name="editform">
	<input type="hidden" name="bBodySubmit" value="1"/>
	<div class="FormSubTitle">#output.label#</div>
	<div class="FormTitle">#application.adminBundle[session.dmProfile.locale].body#</div></cfoutput>
	
	<!--- display texteditor (config specified) --->
	<farcry:richTextEditor value="#output.body#">
	
	<cfoutput><table>
	<tr>
		<td>
			<select onchange="insertHTML(this.options[this.selectedIndex].value);this.selectedIndex=0;">
				<option value="">#application.adminBundle[session.dmProfile.locale].insertImage#</option></cfoutput>
				
				<cfloop list="#relatedItems#" index="id">
					<!--- get object details --->
					<q4:contentobjectget objectid="#id#" r_stobject="stImages">
					<!--- check objectype is an image and path exists --->
					<cfif stImages.typeName eq "dmImage">
						<cfif stImages.imagefile neq "">
							<!--- check if hi res image exists --->
							<cfif stImages.optimisedimage neq "">
								<!--- display normal image with link to high res image in new window --->
								<cfoutput><option value="&lt;a href='#application.url.webroot#/images/#stImages.optimisedimage#' target='_blank'&gt;&lt;img src='#application.url.webroot#/images/#stImages.imagefile#' border=0 alt='#stImages.alt#'&gt;&lt;/a&gt;">#stImages.title#</option></cfoutput>
							<cfelse>
								<!--- display normal image --->
								<cfoutput><option value="&lt;img src='#application.url.webroot#/images/#stImages.imagefile#' border=0 alt='#stImages.alt#'&gt;">#stImages.title#</option></cfoutput>
							</cfif>
						</cfif>
					</cfif>
				</cfloop>
		<cfoutput>	</select>
		</td>
		<td>
				<select onchange="insertHTML(this.options[this.selectedIndex].value);this.selectedIndex=0;">
				<option value="">#application.adminBundle[session.dmProfile.locale].insertFile#</option></cfoutput>
				<cfloop list="#relatedItems#" index="id">
					<!--- get object details --->
					<q4:contentobjectget objectid="#id#" r_stobject="stFiles">
					<!--- check objectype is an file and path exists --->
					<cfif stFiles.typeName eq "dmFile">
						<cfif stFiles.filename neq "">
							<!--- check whether to link directly to file or use download.cfm --->
							<cfif application.config.general.fileDownloadDirectLink eq "false">
								<cfoutput><option value="<a href='#application.url.webroot#/download.cfm?DownloadFile=#id#' target='_blank'>#stFiles.title#</a>">#stFiles.title#</option></cfoutput>
							<cfelse>
								<cfoutput><option value="<a href='#application.url.webroot#/files/#stFiles.filename#' target='_blank'>#stFiles.title#</a>">#stFiles.title#</option></cfoutput>
							</cfif>
						</cfif>
					</cfif>
				</cfloop>
			<cfoutput></select>
		</td></cfoutput>
		
		<!--- add templates --->
		<cfdirectory action="LIST" directory="#application.path.project#/webskin/#output.typename#/" name="qGetTemplates" filter="template*.htm" sort="name ASC">
		<cfif qGetTemplates.recordcount>
			<cfoutput><td>
				<select onchange="insertHTML(this.options[this.selectedIndex].value);this.selectedIndex=0;">
				    <option value="">#application.adminBundle[session.dmProfile.locale].insertTemplate#</option></cfoutput>
					<cfloop query="qGetTemplates">
						<cffile action="READ" file="#application.path.project#/webskin/#output.typename#/#qGetTemplates.name#" variable="i">
					    <!--- get templates--->
					    <cfoutput><option value="#htmleditformat(i)#">#mid(qGetTemplates.name,9,len(qGetTemplates.name))#</option></cfoutput>
				    </cfloop>
				<cfoutput></select>
			</td></cfoutput>	
		</cfif>		
		
		<!--- toggle to textArea instead of editor --->
		<cfoutput><td></cfoutput>

		<cfscript>
        oAuthentication = request.dmSec.oAuthentication;
		aUserGroups = oAuthentication.getMultipleGroups(userLogin="#session.dmSec.authentication.userLogin#", userDirectory="#session.dmSec.authentication.userDirectory#");
		</cfscript>

        <cfset bTogglePerm = 0>
        <cfloop index="i" from="1" to="#arrayLen(aUserGroups)#">
            <cfscript>
            stGroup = aUserGroups[i];
            if (stGroup.groupName eq "SiteAdmin" OR stGroup.groupName eq "SysAdmin") {
                bTogglePerm = 1;
                break;
            }
            </cfscript>
        </cfloop>

        <cfif bTogglePerm>
            <cfoutput><input type="checkbox" name="toggle" onClick="javascript:submit();" <cfif isdefined("session.toggleTextArea") and session.toggleTextArea eq 1>checked</cfif>> #application.adminBundle[session.dmProfile.locale].toggleTextArea#</cfoutput>
        </cfif>

        <cfoutput>
		</td>
	</tr>
	</table></cfoutput>
	
	<farcry:plpNavigationButtons bDropDown="true" onClick="#onClickEvent#">
	
	<cfoutput></form></cfoutput>
	
<cfelse>
	<farcry:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="No">
