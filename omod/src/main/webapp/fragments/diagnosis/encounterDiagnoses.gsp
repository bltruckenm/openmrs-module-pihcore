<%
    config.require("formFieldName")

    ui.includeJavascript("uicommons", "angular.min.js")
    ui.includeJavascript("coreapps", "diagnoses/diagnoses.js")
    ui.includeJavascript("coreapps", "diagnoses/diagnoses-angular.js")
    ui.includeCss("coreapps", "diagnoses/encounterDiagnoses.css")
%>

<% /* This is an underscore template, since I don't know how to use angular templates programmatically */ %>
<script type="text/template" id="autocomplete-render-item">
    <span class="code">
        {{ if (item.code) { }}
        {{- item.code }}
        {{ } else if (item.concept) { }}
        ${ui.message("emr.consult.codedButNoCode")}
        {{ } else { }}
        ${ui.message("emr.consult.nonCoded")}
        {{ } }}
    </span>
    <strong class="matched-name">
        {{- item.matchedName }}
    </strong>
    {{ if (item.preferredName) { }}
    <span class="preferred-name">
        <small>${ui.message("emr.consult.synonymFor")}</small>
        {{- item.concept.preferredName }}
    </span>
    {{ } }}
</script>

<div id="encounter-diagnoses-app">

    <script type="text/ng-template" id="selected-diagnosis">
        <div class="diagnosis" data-ng-class="{primary: d.primary}">
            <span class="code">
                <span data-ng-show="d.diagnosis.code">{{ d.diagnosis.code }}</span>
                <span data-ng-show="!d.diagnosis.code && d.diagnosis.concept">
                    ${ui.message("emr.consult.codedButNoCode")}
                </span>
                <span data-ng-show="!d.diagnosis.code && !d.diagnosis.concept">
                    ${ui.message("emr.consult.nonCoded")}
                </span>
            </span>
            <strong class="matched-name">{{ d.diagnosis.matchedName }}</strong>
            <span class="preferred-name" data-ng-show="d.diagnosis.preferredName">
                <small>${ui.message("emr.consult.synonymFor")}</small>
                <span>{{ d.diagnosis.concept.preferredName }}</span>
            </span>

            <div class="actions">
                <label>
                    <input type="checkbox" data-ng-model="d.primary"/>
                    ${ui.message("emr.Diagnosis.Order.PRIMARY")}
                </label>
                <label>
                    <input type="checkbox" data-ng-model="d.confirmed"/>
                    ${ui.message("emr.Diagnosis.Certainty.CONFIRMED")}
                </label>
            </div>
        </div>
        <i data-ng-click="removeDiagnosis(d)" tabindex="-1" class="icon-remove delete-item"></i>
    </script>

    <div data-ng-controller="DiagnosesController">

        <div id="diagnosis-search-container">
            <label for="diagnosis-search">${ ui.message("emr.consult.addDiagnosis") }</label>
            <input id="diagnosis-search" type="text" placeholder="${ ui.message("emr.consult.addDiagnosis.placeholder") }" autocomplete itemFormatter="autocomplete-render-item"/>
        </div>

        <div id="display-diagnoses-container">
            <h3>${ui.message("emr.consult.primaryDiagnosis")}</h3>

            <div data-ng-show="encounterDiagnoses.primaryDiagnoses().length == 0">
                ${ui.message("emr.consult.primaryDiagnosis.notChosen")}
            </div>
            <ul>
                <li data-ng-repeat="d in encounterDiagnoses.primaryDiagnoses()">
                    <span data-ng-include="'selected-diagnosis'"></span>
                </li>
            </ul>
            <br/>

            <h3>${ui.message("emr.consult.secondaryDiagnoses")}</h3>

            <div data-ng-show="encounterDiagnoses.secondaryDiagnoses().length == 0">
                ${ui.message("emr.consult.secondaryDiagnoses.notChosen")}
            </div>
            <ul>
                <li data-ng-repeat="d in encounterDiagnoses.secondaryDiagnoses()">
                    <span data-ng-include="'selected-diagnosis'"></span>
                </li>
            </ul>
        </div>

        <textarea style="display:none" name="${ config.formFieldName }">{{ valueToSubmit() }}</textarea>
    </div>
</div>

<script type="text/javascript">
    // manually bootstrap, in case there are multiple angular apps on a page
    angular.bootstrap('#encounter-diagnoses-app', ['diagnoses']);

    // add any existing diagnoses
    angular.element('#encounter-diagnoses-app').scope().\$apply(function() {
        var encounterDiagnoses = angular.element('#encounter-diagnoses-app > .ng-scope').scope().encounterDiagnoses;
        <% jsForExisting.each { %>
            encounterDiagnoses.addDiagnosis(diagnoses.Diagnosis(${ it }));
        <% } %>
    });
</script>