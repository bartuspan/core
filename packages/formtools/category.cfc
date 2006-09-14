




<cfcomponent extends="field" name="category" displayname="category" hint="Field component to liase with all category field types"> 

	<cfimport taglib="/farcry/farcry_core/tags/widgets/" prefix="widgets">
	<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >

		
	<cffunction name="init" access="public" returntype="farcry.farcry_core.packages.formtools.category" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="false" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfparam name="arguments.stMetadata.ftAlias" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftLegend" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftRenderType" default="Tree" type="string" />
		<cfparam name="arguments.stMetadata.ftSelectMultiple" default="true" type="boolean" />
		<cfparam name="arguments.stMetadata.ftSelectSize" default="1" type="numeric" />
		
		<cfif structKeyExists(application.catid, arguments.stMetadata.ftAlias)>
			<cfset navid = application.catid[arguments.stMetadata.ftAlias] >
		<cfelse>
			<cfset navid = application.catid['root'] >
		</cfif>

		<cfset oCategory = createObject("component",'farcry.farcry_core.packages.farcry.category')>
		
		<cfset lSelectedCategoryID = oCategory.getCategories(objectid=arguments.stObject.ObjectID,bReturnCategoryIDs=true)>

		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
			
			<cfcase value="dropdown">
				<cfset lCategoryBranch = oCategory.getCategoryBranchAsList(lCategoryIDs=navid) />
							
				<cfsavecontent variable="html">
					<cfoutput><fieldset></cfoutput>
					<cfoutput><select id="#arguments.fieldname#" name="#arguments.fieldname#" size="#arguments.stMetadata.ftSelectSize#" <cfif arguments.stMetadata.ftSelectMultiple> multiple="true"</cfif>></cfoutput>
					<cfloop list="#lCategoryBranch#" index="i">
						<cfset CategoryName = oCategory.getCategoryNamebyID(categoryid=i,typename='categories') />
						<cfoutput><option value="#i#">#CategoryName#</option></cfoutput>
					</cfloop>
					<cfoutput></select></cfoutput>
					<cfoutput></fieldset></cfoutput>
				</cfsavecontent>
			</cfcase>
			
			<cfdefaultcase>
				<cfsavecontent variable="html">
					
						<cfoutput><fieldset style="width: 300px;">
							<cfif len(arguments.stMetadata.ftLegend)><legend>#arguments.stMetadata.ftLegend#</legend></cfif>
						
							<div class="fieldsection optional full">
													
								<div class="fieldwrap">
								</cfoutput>
<!---									<ft:prototypeTree id="#arguments.fieldname#" navid="#navid#" depth="99" bIncludeHome=1 lSelectedItems="#lSelectedCategoryID#" bSelectMultiple="#arguments.stMetadata.ftSelectMultiple#">
										<ft:prototypeTreeNode>
											<ft:prototypeTreeNode>
											
											</ft:prototypeTreeNode>
										</ft:prototypeTreeNode>
									</ft:prototypeTree> --->
									<ft:NTMPrototypeTree id="#arguments.fieldname#" navid="#navid#" depth="99" bIncludeHome=1 lSelectedItems="#lSelectedCategoryID#" bSelectMultiple="#arguments.stMetadata.ftSelectMultiple#">
								
								<cfoutput>
								</div>
								
								<br class="fieldsectionbreak" />
							</div>
							<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" />
						</fieldset></cfoutput>
								
				</cfsavecontent>
			</cfdefaultcase>
			
		</cfswitch>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfparam name="arguments.stMetadata.ftAlias" default="">
	
		<cfinvoke component="#application.packagepath#.farcry.category" method="getCategories" returnvariable="lSelectedCategoryID">
			<cfinvokeargument name="objectID" value="#stObject.ObjectID#"/>
			<cfinvokeargument name="bReturnCategoryIDs" value="false"/>
			<cfinvokeargument name="alias" value="#arguments.stMetadata.ftAlias#"/>
		</cfinvoke>
		
		<cfsavecontent variable="html">
			<cfoutput>#lSelectedCategoryID#</cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="ObjectID" required="true" type="UUID" hint="The objectid of the object that this field is part of.">
		<cfargument name="Typename" required="true" type="string" hint="the typename of the objectid.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = "#arguments.stFieldPost.Value#">
		<cfset stResult.stError = StructNew()>
		
		<cfparam name="arguments.stMetadata.ftAlias" default="">
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->

		<cfinvoke  component="#application.packagepath#.farcry.category" method="assignCategories" returnvariable="stStatus">
			<cfinvokeargument name="objectID" value="#arguments.ObjectID#"/>
			<cfinvokeargument name="lCategoryIDs" value="#arguments.stFieldPost.Value#"/>
			<cfinvokeargument name="alias" value="#arguments.stMetadata.ftAlias#"/>
			<cfinvokeargument name="dsn" value="#application.dsn#"/>
		</cfinvoke>

					
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>

</cfcomponent> 



