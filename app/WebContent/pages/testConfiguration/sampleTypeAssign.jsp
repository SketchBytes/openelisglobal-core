<%@ page language="java"
         contentType="text/html; charset=utf-8"
         import="us.mn.state.health.lims.common.action.IActionConstants"
        %>
<%@ page import="us.mn.state.health.lims.common.util.IdValuePair" %>
<%@ page import="us.mn.state.health.lims.common.util.StringUtil" %>
<%@ page import="us.mn.state.health.lims.common.util.Versioning" %>
<%@ page import="java.util.List" %>

<%@ taglib uri="/tags/struts-bean" prefix="bean" %>
<%@ taglib uri="/tags/struts-html" prefix="html" %>
<%@ taglib uri="/tags/struts-logic" prefix="logic" %>
<%@ taglib uri="/tags/labdev-view" prefix="app" %>
<%--
  ~ The contents of this file are subject to the Mozilla Public License
  ~ Version 1.1 (the "License"); you may not use this file except in
  ~ compliance with the License. You may obtain a copy of the License at
  ~ http://www.mozilla.org/MPL/
  ~
  ~ Software distributed under the License is distributed on an "AS IS"
  ~ basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
  ~ License for the specific language governing rights and limitations under
  ~ the License.
  ~
  ~ The Original Code is OpenELIS code.
  ~
  ~ Copyright (C) ITECH, University of Washington, Seattle WA.  All Rights Reserved.
  --%>

<script type="text/javascript" src="scripts/ajaxCalls.js?ver=<%= Versioning.getBuildNumber() %>"></script>
<script type="text/javascript" src="scripts/jquery-ui.js?ver=<%= Versioning.getBuildNumber() %>"></script>


<bean:define id="formName" value='<%= (String)request.getAttribute(IActionConstants.FORM_NAME) %>'/>
<bean:define id="sampleTypeList" name='<%=formName%>' property="sampleTypeList" type="java.util.List"/>


<%!
    String basePath = "";
    int testCount = 0;
    int columnCount = 0;
    int columns = 3;
    int columnSize = (int) (100 / columns);
%>

<%
    basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
    columnCount = 0;
    testCount = 0;
%>

<link rel="stylesheet" media="screen" type="text/css"
      href="<%=basePath%>css/jquery_ui/jquery.ui.theme.css?ver=<%= Versioning.getBuildNumber() %>"/>

<form>
<script type="text/javascript">
    if (!$jq) {
        var $jq = jQuery.noConflict();
    }

    $jq(document).ready( function(){
        $jq(".sortable").sortable({
            stop: function( ) {makeDirty();}
        });
    });

    function makeDirty(){
        function formWarning(){
            return "<bean:message key="banner.menu.dataLossWarning"/>";
        }
        window.onbeforeunload = formWarning;
    }

    function submitAction(target) {
        var form = window.document.forms[0];
        form.action = target;
        form.submit();
    }

    function testSelected(input, id, currentSampleType, onlyOneTestInSampleType, sampleTypeId) {
        makeDirty();
        $jq(".test").each(function () {
            $jq(this).attr("disabled", "disabled");
            $jq(this).addClass("disabled-text-button");
        });

        $jq(".selectedTestName").text(input.value);
        $jq("#action").text('<bean:message key="label.button.edit"/>');
        $jq("#fromSampleType").text(currentSampleType);
        $jq("#testId").val(id);
        $jq("#deactivateSampleTypeId").val(onlyOneTestInSampleType ? sampleTypeId : "");
        $jq("#warnDeactivteSampleType").text(currentSampleType);
        $jq(".edit-step").show();
        $jq(".select-step").hide();
        $jq(window).scrollTop(0);

    }

    function sampleTypeSelected( selection){
        var optionId = $jq(selection).val();
        $jq("#saveButton").attr("disabled", (0 == optionId));
        $jq("#toSampleType").text($jq("#option_" + optionId).text());
        $jq("#sampleTypeId").val(optionId);
    }

    function confirmValues() {
        $jq("#editButtons").hide();
        $jq(".confirmation-step").show();
        $jq("#action").text('<%=StringUtil.getMessageForKey("label.confirmation")%>');
        if( $jq("#deactivateSampleTypeId").val().length > 0){
            $jq("#deatcitvateWarning").show();
        }else{
            $jq("#deatcitvateWarning").hide();
        }

        $jq("#sampleTypeSelection").attr("disabled", true);

    }

    function rejectConfirmation() {
        $jq("#editButtons").show();
        $jq(".confirmation-step").hide();
        $jq("#action").text('<%=StringUtil.getMessageForKey("label.button.edit")%>');

        $jq("#sampleTypeSelection").attr("disabled", false);
    }


    function savePage() {
        window.onbeforeunload = null; // Added to flag that formWarning alert isn't needed.
        var form = window.document.forms[0];
        form.action = "SampleTypeTestAssignUpdate.do";
        form.submit();
    }
</script>
    <html:hidden name="<%=formName%>" property="testId" styleId="testId"/>
    <html:hidden name="<%=formName%>" property="sampleTypeId" styleId="sampleTypeId"/>
    <html:hidden name="<%=formName%>" property="deactivateSampleTypeId" styleId="deactivateSampleTypeId"/>

    <input type="button" value='<%= StringUtil.getMessageForKey("banner.menu.administration") %>'
           onclick="submitAction('MasterListsPage.do');"
           class="textButton"/>&rarr;
    <input type="button" value='<%= StringUtil.getMessageForKey("configuration.test.management") %>'
           onclick="submitAction('TestManagementConfigMenu.do');"
           class="textButton"/>&rarr;
    <input type="button" value='<%= StringUtil.getMessageForKey("configuration.sampleType.manage") %>'
           onclick="submitAction('SampleTypeManagement.do');"
           class="textButton"/>&rarr;

<%=StringUtil.getMessageForKey( "configuration.sampleType.assign" )%>
<br><br>

    <h1 id="action" ><bean:message key="label.form.select"/></h1>
    <h1 id="action" class="edit-step" style="display: none"></h1>
    <h2><bean:message key="configuration.sampleType.assign"/> </h2>

    <div class="select-step" >
        <bean:message key="configuration.sampleType.assign.explain" />
    </div>
    <div class="edit-step" style="display:none">

        Test: <span class="selectedTestName" ></span><br><br>
        &nbsp;&nbsp;<bean:message key="configuration.sampleType.assign.new.type" />:&nbsp;
    <select id="sampleTypeSelection" onchange="sampleTypeSelected(this);">

        <% for(int i = 0; i < sampleTypeList.size(); i++){
            IdValuePair sampleType = (IdValuePair)sampleTypeList.get(i);
        %>
        <option id='<%="option_" + sampleType.getId()%>' value="<%=sampleType.getId()%>"><%=sampleType.getValue()%></option>
        <% } %>
    </select>

    <div class="confirmation-step" style="display:none">
        <br><span class="selectedTestName" ></span>&nbsp;<bean:message key="configuration.sampleType.confirmation.move.phrase" />&nbsp;<span id="fromSampleType" ></span> <bean:message key="word.to" /> <span id="toSampleType" ></span>.
        <div id="deatcitvateWarning" >
            <br/><span id="warnDeactivteSampleType"></span>&nbsp;<bean:message key="configuration.sampleType.assign.deactivate" />
        </div>
    </div>

    <div style="text-align: center" id="editButtons">
        <input id="saveButton" type="button" value='<%=StringUtil.getMessageForKey("label.button.next")%>'
               onclick="confirmValues();" disabled="disabled"/>
        <input type="button" value='<%=StringUtil.getMessageForKey("label.button.previous")%>'
               onclick='window.onbeforeunload = null; submitAction("SampleTypeTestAssign.do")'/>
    </div>
    <div style="text-align: center; display: none;" class="confirmation-step">
        <input type="button" value='<%=StringUtil.getMessageForKey("label.button.accept")%>'
               onclick="savePage();"/>
        <input type="button" value='<%=StringUtil.getMessageForKey("label.button.reject")%>'
               onclick='rejectConfirmation();'/>
    </div>
</div>
    <bean:define id="testMap" name='<%=formName%>' property="sampleTypeTestList" type="java.util.LinkedHashMap<IdValuePair, java.util.List<IdValuePair>>"/>

<% for( IdValuePair pair : testMap.keySet()){
 List<IdValuePair> testList = testMap.get(pair);
 %>
    <div>
        <h4><%=pair.getValue()%></h4>
        <% testCount = 0;%>
        <table width="95%" style="position:relative;left:5%">
            <% while (testCount < testList.size()) {%>
            <tr>
                <%
                    columnCount = 0;
                %>
                <% while (testCount < testList.size() && (columnCount < columns)) {%>
                <td width='<%=columnSize + "%"%>'>
                    <input type="button"
                           class="textButton test"
                           value='<%=testList.get(testCount).getValue()%>'
                           onclick="testSelected(this, '<%=testList.get(testCount).getId() %>', '<%=pair.getValue()%>', <%= testList.size() == 1 %>, '<%=pair.getId()%>')"
                           checked>
                    <%
                        testCount++;
                        columnCount++;
                    %></td>
                <% } %>
                <% while (columnCount < columns) {
                    columnCount++; %>
                <td width='<%=columnSize + "%"%>'></td>
                <% } %>
            </tr>
            <% } %>
        </table>

    </div>
<%}%>
