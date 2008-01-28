

<cfcomponent name="datetime" extends="field" displayname="datetime" hint="Field component to liase with all datetime types"> 
		
	<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" >	
	<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" >		
		
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.datetime" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var fieldStyle = "">
		<cfset var ToggleOffDateTimeJS = "" />
		<cfset var html = "" />
		<cfset var bfieldvisible = "" />
		<cfset var fieldvisibletoggletext = "" />
		<cfset var locale = "">
		<cfset var localeMonths = "">
		<cfset var i = "">
		<cfset var step=1>
		
		<cfparam name="arguments.stMetadata.ftRenderType" default="dateJS">	
		<cfparam name="arguments.stMetadata.ftToggleOffDateTime" default="1">
		
			
		<cfif arguments.stMetadata.ftToggleOffDateTime>
			<cfset Request.InHead.ScriptaculousEffects = 1>
			
			<cfif len(arguments.stMetadata.value) AND (not IsDate(arguments.stMetadata.value) OR DateDiff('yyyy', now(), arguments.stMetadata.value) GT 100 OR dateformat(arguments.stMetadata.value, 'dd/mm/yyyy') eq '01/01/2050') >
				<cfset bfieldvisible = 0>
				<cfset fieldStyle = "display:none;">
			<cfelse>
				<cfset bfieldvisible = 1>
				<cfset fieldStyle = "">
			</cfif>	
			
			
			<cfsavecontent variable="ToggleOffDateTimeJS">
				<cfoutput>
					<script language="javascript">
					var bfieldvisible#arguments.fieldname# = #bfieldvisible#;
					
					function toggle#arguments.fieldname#(){
							
						if (bfieldvisible#arguments.fieldname# == 0){
							Effect.BlindDown('#arguments.fieldname#DIV');
							bfieldvisible#arguments.fieldname# = 1;
						} else {
							Effect.BlindUp('#arguments.fieldname#DIV');
							bfieldvisible#arguments.fieldname# = 0;
						}
						
						//return true;
					}					

					</script>
				</cfoutput>
			</cfsavecontent>
			
			<cfhtmlhead text="#ToggleOffDateTimeJS#">
		</cfif>		
		
		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
		
		<cfcase value="dropdown">
			<cfparam name="arguments.stMetadata.ftDateFormatMask" default="dd mmm yyyy">
			<cfparam name="arguments.stMetadata.ftStartYearShift" default="0">
			<cfparam name="arguments.stMetadata.ftEndYearShift" default="-100">
			<cfparam name="arguments.stMetadata.ftStartYear" default="#year(now()) + arguments.stMetadata.ftStartYearShift#">
			<cfparam name="arguments.stMetadata.ftEndYear" default="#year(now()) + arguments.stMetadata.ftEndYearShift#">
			
			<cfif arguments.stMetadata.ftStartYear gt arguments.stMetadata.ftEndYear>
				<cfset step=-1 />
			</cfif>
			
			<cfif isDefined("session.dmProfile.locale") AND len(session.dmProfile.locale)>
				<cfset locale = session.dmProfile.locale>
			<cfelse>
				<cfset locale = "en_AU">
			</cfif>			
			
			<cfset localeMonths = createObject("component", "/farcry/core/packages/farcry/gregorianCalendar").getMonths(locale) />
	
			<cfsavecontent variable="html">
				<cfoutput>
				<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#DateFormat(arguments.stMetadata.value,arguments.stMetadata.ftDateFormatMask)#" />
				<input type="hidden" name="#arguments.fieldname#rendertype" id="#arguments.fieldname#rendertype" value="#arguments.stMetadata.ftRenderType#">
				
				<div  id="#arguments.fieldname#DIV" style="float:left;#fieldstyle#">
					<select name="#arguments.fieldname#Day" id="#arguments.fieldname#Day">
					<option value="">--</option>
					<cfloop from="1" to="31" index="i">
						<option value="#i#"<cfif isDate(arguments.stMetadata.value) AND Day(arguments.stMetadata.value) EQ i> selected="selected"</cfif>>#i#</option>
						</cfloop>
					</select>	
				
					<select name="#arguments.fieldname#Month" id="#arguments.fieldname#Month">
						<option value="">--</option>
						<cfloop from="1" to="12" index="i">
							<option value="#i#"<cfif isDate(arguments.stMetadata.value) AND Month(arguments.stMetadata.value) EQ i> selected="selected"</cfif>>#localeMonths[i]#</option>
						</cfloop>
					</select>
				
					<select name="#arguments.fieldname#Year" id="#arguments.fieldname#Year">
						<option value="">--</option>
						<cfloop from="#arguments.stMetadata.ftStartYear#" to="#arguments.stMetadata.ftEndYear#" index="i" step="#step#">
							<option value="#i#"<cfif isDate(arguments.stMetadata.value) AND Year(arguments.stMetadata.value) EQ i> selected="selected"</cfif>>#i#</option>
						</cfloop>
					</select>	
				</div>
				<br style="clear:both;" />						
				
				</cfoutput>
			</cfsavecontent>		
			
			<cfreturn html>
		</cfcase>
		
		
		<cfdefaultcase>
			
			<cfparam name="arguments.stMetadata.ftStyle" default="width:160px;">
			<cfparam name="arguments.stMetadata.ftDateFormatMask" default="dd MMM yyyy">
			<cfparam name="arguments.stMetadata.ftTimeFormatMask" default="hh:mm tt">
			<cfparam name="arguments.stMetadata.ftShowTime" default="true">		
			<cfparam name="arguments.stMetadata.ftDateLocale" default="en-AU">		
			<cfparam name="arguments.stMetadata.ftShowCalendar" default="true">		
			<cfparam name="arguments.stMetadata.ftShowSuggestions" default="true">	
			
			<cfset arguments.stMetadata.ftShowTime = true />
			<!--- Just in case the developer has included lowercase mmmm or mmm which is not valid, we are changing to uppercase MMMM and MMM respectively. --->
			<cfset arguments.stMetadata.ftDateFormatMask = replaceNoCase(arguments.stMetadata.ftDateFormatMask, "mmmm", "MMMM", "all") />
			<cfset arguments.stMetadata.ftDateFormatMask = replaceNoCase(arguments.stMetadata.ftDateFormatMask, "mmm", "MMM", "all") />			
			

			<!--- 
			FormatSpecifiers   
			Format Specifiers are used to specify date formats for display and input.
			
			Format  Description                                                                  Example
			------  ---------------------------------------------------------------------------  -----------------------
			 s      The seconds of the minute between 0-59.                                      "0" to "59"
			 ss     The seconds of the minute with leading zero if required.                     "00" to "59"
			 
			 m      The minute of the hour between 0-59.                                         "0"  or "59"
			 mm     The minute of the hour with leading zero if required.                        "00" or "59"
			 
			 h      The hour of the day between 1-12.                                            "1"  to "12"
			 hh     The hour of the day with leading zero if required.                           "01" to "12"
			 
			 H      The hour of the day between 0-23.                                            "0"  to "23"
			 HH     The hour of the day with leading zero if required.                           "00" to "23"
			 
			 d      The day of the month between 1 and 31.                                       "1"  to "31"
			 dd     The day of the month with leading zero if required.                          "01" to "31"
			 ddd    Abbreviated day name. Date.CultureInfo.abbreviatedDayNames.                  "Mon" to "Sun" 
			 dddd   The full day name. Date.CultureInfo.dayNames.                                "Monday" to "Sunday"
			 
			 M      The month of the year between 1-12.                                          "1" to "12"
			 MM     The month of the year with leading zero if required.                         "01" to "12"
			 MMM    Abbreviated month name. Date.CultureInfo.abbreviatedMonthNames.              "Jan" to "Dec"
			 MMMM   The full month name. Date.CultureInfo.monthNames.                            "January" to "December"
			
			 yy     Displays the year as a two-digit number.                                     "99" or "07"
			 yyyy   Displays the full four digit year.                                           "1999" or "2007"
			 
			 t      Displays the first character of the A.M./P.M. designator.                    "A" or "P"
			        Date.CultureInfo.amDesignator or Date.CultureInfo.pmDesignator
			 tt     Displays the A.M./P.M. designator.                                           "AM" or "PM"
			        Date.CultureInfo.amDesignator or Date.CultureInfo.pmDesignator
			 --->						
					
			<skin:htmlHead library="extjs" />
			<skin:htmlHead id="dateJS">
				<cfoutput><script type="text/javascript" src="#application.url.webtop#/js/dateJS/date-#arguments.stMetadata.ftDateLocale#.js"></script></cfoutput>
				<cfoutput>
				<style type="text/css">
				.dateSuggestions {padding:0px 0px 0px 25px;background: ##efefef url('#application.url.webtop#/js/dateJS/images/information.png') top left no-repeat;}
				.dateJSHiddenValue {padding:0px 0px 0px 25px;}
				.dateEmpty {background: ##fff url('#application.url.webtop#/js/dateJS/images/star.png') top left no-repeat;}
				.dateAccept {background: ##fff url('#application.url.webtop#/js/dateJS/images/accept.png') top left no-repeat;}
				.dateError {background: ##fff url('#application.url.webtop#/js/dateJS/images/exclamation.png') top left no-repeat;}
				</style>
				
				<script type="text/javascript">
					function updateDateJSField(fieldName, mask){
				    	var el = Ext.get(fieldName + "Info");
				    	var dateString = Ext.get(fieldName + "Input").dom.value;
				    	
				    	el.removeClass('dateEmpty');
						el.removeClass('dateAccept');
						el.removeClass('dateError');
							
				    	if (dateString.length > 0) {
					    	var parsedValue = Date.parse(dateString)
					    	if (parsedValue !== null) {
								el.addClass('dateAccept');	
								Ext.get(fieldName + "Info").dom.innerHTML = parsedValue.toString(mask);
								Ext.get(fieldName).dom.value = parsedValue.toString('yyyy/MMM/dd hh:mm tt');
							} else {
								el.addClass('dateError');	
								Ext.get(fieldName + "Info").dom.innerHTML = 'NOT A VALID DATE';
								Ext.get(fieldName).dom.value = '';
							}
						} else {
				
							el.addClass('dateEmpty');					
							Ext.get(fieldName + "Info").dom.innerHTML = 'Type in your date';
							Ext.get(fieldName).dom.value = '';
						}
					}
				</script>
				</cfoutput>				
			</skin:htmlHead>
			
			<extjs:onReady>
				<cfoutput>	
					Ext.get("#arguments.fieldname#Input").on('keyup', this.onClick, this, {
					    buffer: 200,
					    fn: function() { 
					    	updateDateJSField('#arguments.fieldname#', '#arguments.stMetadata.ftDateFormatMask# #arguments.stMetadata.ftTimeFormatMask#');
						 }
					});
					Ext.get("#arguments.fieldname#Input").on('focus', this.onClick, this, {
					    buffer: 200,
					    fn: function() { 
					    	if (Ext.get("#arguments.fieldname#Input").dom.value == 'Type in your date') {
					    		Ext.get("#arguments.fieldname#Input").dom.value = '';
					    	}
						 }
					});
				</cfoutput>			
			</extjs:onReady>	
			
						
			<cfsavecontent variable="html">
				<cfif arguments.stMetadata.ftToggleOffDateTime>
					<cfoutput>
					<div style="float:left;margin-right:10px;">
						<input type="checkbox" name="#arguments.fieldname#include" id="#arguments.fieldname#include" class="formCheckbox" value="1" onclick="javascript:toggle#arguments.fieldname#();" <cfif bfieldvisible>checked="true"</cfif> >
						<input type="hidden" name="#arguments.fieldname#include" id="#arguments.fieldname#include" value="0">
					</div>
					</cfoutput>
				</cfif>
				
				
				<cfoutput>
					<div  id="#arguments.fieldname#DIV" style="float:left;#fieldstyle#">
						<span id="#arguments.fieldname#Info" class="dateJSHiddenValue <cfif len(arguments.stMetadata.value)>dateAccept<cfelse>dateEmpty</cfif>">#DateFormat(arguments.stMetadata.value,arguments.stMetadata.ftDateFormatMask)# <cfif arguments.stMetadata.ftShowTime>#TimeFormat(arguments.stMetadata.value,arguments.stMetadata.ftTimeFormatMask)#</cfif></span>
						<input type="text" id="#arguments.fieldname#Input" name="#arguments.fieldname#Input" value="Type in your date" />
						<a id="#arguments.fieldname#DatePicker"><img src="#application.url.farcry#/js/dateTimePicker/cal.gif" width="16" height="16" border="0" alt="Pick a date"></a>
						<cfif arguments.stMetadata.ftShowSuggestions><div class="dateSuggestions">Examples: tomorrow; next tues at 5am; +5days;</div></cfif>
					</div>
					<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="#DateFormat(arguments.stMetadata.value,'yyyy/mmm/dd')# #TimeFormat(arguments.stMetadata.value, 'hh:mm tt')#">
				</cfoutput>
				
				<cfif arguments.stMetadata.ftShowCalendar>
					<skin:htmlhead library="calendar" />
					<cfoutput>
						<script type="text/javascript">
						  Calendar.setup(
						    {
							  inputField	: "#arguments.fieldname#",         // ID of the input field 
						      button		: "#arguments.fieldname#DatePicker",       // ID of the button
						      showsTime		: #arguments.stMetadata.ftShowTime#,
						      electric		: false,
						      ifFormat		: "%Y/%b/%d %I:%M %p",
						      onClose		: function(calendar) {	
						      	if (calendar.dateClicked) { 
							      	
						      		Ext.get("#arguments.fieldname#Input").dom.value = Date.parse(calendar.date).toString("#arguments.stMetadata.ftDateFormatMask# <cfif arguments.stMetadata.ftShowTime>#arguments.stMetadata.ftTimeFormatMask#</cfif>");
							      	updateDateJSField('#arguments.fieldname#', '#arguments.stMetadata.ftDateFormatMask# <cfif arguments.stMetadata.ftShowTime>#arguments.stMetadata.ftTimeFormatMask#</cfif>');	
							      	Ext.get("#arguments.fieldname#Input").dom.value = '';
						      	}
							    calendar.hide();					      						
						      }
						    }
						  );
						</script>
					</cfoutput>
				</cfif>
			</cfsavecontent>	
				

				
			
			<cfreturn html>	
		</cfdefaultcase>

		</cfswitch>
		

	</cffunction>

	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		
		
		<cfparam name="arguments.stMetadata.ftDateMask" default="d-mmm-yy">
		<cfparam name="arguments.stMetadata.ftTimeMask" default="short">
		<cfparam name="arguments.stMetadata.ftShowTime" default="false">
		
		<cfsavecontent variable="html">
			<cfif len(arguments.stMetadata.value)>
				<cfoutput>#DateFormat(arguments.stMetadata.value,arguments.stMetadata.ftDateMask)#</cfoutput>
				<cfif arguments.stMetadata.ftShowTime>
					<cfoutput> #TimeFormat(arguments.stMetadata.value,arguments.stMetadata.ftTimeMask)# </cfoutput>
				</cfif>				
			</cfif>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		

		<cfset var stResult = passed(value="") />
		<cfset var newDate = "" />
		
		<cfparam name="arguments.stFieldPost.stSupporting.renderType" default="calendar">
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		
		
		
		<cfswitch expression="#arguments.stFieldPost.stSupporting.renderType#">
		
		<cfcase value="dropdown">
			
			<!--- --------------------------- --->
			<!--- Perform any validation here --->
			<!--- --------------------------- --->
			<cfif structKeyExists(arguments.stFieldPost.stSupporting,"day")
				AND structKeyExists(arguments.stFieldPost.stSupporting,"month")
				AND structKeyExists(arguments.stFieldPost.stSupporting,"year")>
				
				<cfif len(arguments.stFieldPost.stSupporting.day) OR len(arguments.stFieldPost.stSupporting.month) OR len(arguments.stFieldPost.stSupporting.year)>
					<cftry>
						<cfset newDate = createDate(arguments.stFieldPost.stSupporting.year, arguments.stFieldPost.stSupporting.month, arguments.stFieldPost.stSupporting.day) />
						<cfset stResult = passed(value="#newDate#") />
						<cfcatch type="any">
							<cfset stResult = failed(value="#arguments.stFieldPost.value#", message="You need to select a valid date.") />
						</cfcatch>
					</cftry>
				<cfelseif structKeyExists(arguments.stMetadata, "ftValidation") AND listFindNoCase(arguments.stMetadata.ftValidation, "required")>
					<cfset stResult = failed(value="#arguments.stFieldPost.value#", message="This is a required field") />
				</cfif>
			<cfelseif structKeyExists(arguments.stMetadata, "ftValidation") AND listFindNoCase(arguments.stMetadata.ftValidation, "required")>
				<cfset stResult = failed(value="#arguments.stFieldPost.value#", message="This is a required field") />
			</cfif>
					
			<cfif stResult.bSuccess>
				<cfset arguments.stFieldPost.value = stResult.value />
				<cfset stResult = super.validate(objectid=arguments.objectid, typename=arguments.typename, stFieldPost=arguments.stFieldPost, stMetadata=arguments.stMetadata )>
			</cfif>
		
			<!--- ----------------- --->
			<!--- Return the Result --->
			<!--- ----------------- --->
			<cfreturn stResult>		
		</cfcase>
		
		<cfdefaultcase>
			<cfparam name="arguments.stFieldPost.stSupporting.Include" default="true">
			
			<cfif ListGetAt(arguments.stFieldPost.stSupporting.Include,1)>
			
				<cftry>
					<cfset newDate = CreateODBCDateTime("#arguments.stFieldPost.Value#") />
					<cfset stResult = passed(value="#newDate#") />
					<cfcatch type="any">
						<cfset stResult = failed(value="#arguments.stFieldPost.value#", message="You need to select a valid date.") />
					</cfcatch>
				</cftry>
				
			<cfelse>
				<cfset newDate = CreateODBCDateTime("#DateAdd('yyyy',200,now())#") />
				<cfset stResult = passed(value="#newDate#") />
			</cfif>
		
			<cfif stResult.bSuccess>
				<cfset arguments.stFieldPost.value = stResult.value />
				<cfset stResult = super.validate(objectid=arguments.objectid, typename=arguments.typename, stFieldPost=arguments.stFieldPost, stMetadata=arguments.stMetadata )>
			</cfif>
			
			<!--- ----------------- --->
			<!--- Return the Result --->
			<!--- ----------------- --->
			<cfreturn stResult>
		</cfdefaultcase>
		</cfswitch>
		

		
	</cffunction>

</cfcomponent> 
