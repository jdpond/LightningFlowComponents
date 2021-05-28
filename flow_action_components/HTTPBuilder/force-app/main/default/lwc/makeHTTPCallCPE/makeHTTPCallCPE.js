import { LightningElement, track, api } from 'lwc';
import makeTestRESTCall from "@salesforce/apex/MakeHTTPCallCPEController.makeTestHTTPCallout";
import urlLabel from '@salesforce/label/c.url';
import HTTP_Method from '@salesforce/label/c.HTTP_Method';
import Specify_Params from '@salesforce/label/c.Specify_Params';
import Timeout_in_ms from '@salesforce/label/c.Timeout_in_ms';
import Add_Param from '@salesforce/label/c.Add_Param';
import Specify_Headers from '@salesforce/label/c.Specify_Headers';
import Add_Header from '@salesforce/label/c.Add_Header';
import Body_Label from '@salesforce/label/c.Body_Label';
import Compress_Request_body_to_gzip from '@salesforce/label/c.Compress_Request_body_to_gzip';
import Request_Body_as_Blob from '@salesforce/label/c.Request_Body_as_Blob';
import Test_Callout from '@salesforce/label/c.Test_Callout';
import Response_Result from '@salesforce/label/c.Response_Result';
import Error_Message from '@salesforce/label/c.Error_Message';
import Status from '@salesforce/label/c.Status';
import Status_code from '@salesforce/label/c.Status_code';
import Make_HTTP_Call from '@salesforce/label/c.Make_HTTP_Call';


const METHOD_LIST = [
    {value: 'GET', label: 'GET'},
    {value: 'POST', label: 'POST'},
    {value: 'PATCH', label: 'PATCH'},
    {value: 'PUT', label: 'PUT'},
    {value: 'DELETE', label: 'DELETE'},
    {value: 'TRACE', label: 'TRACE'},
    {value: 'CONNECT', label: 'CONNECT'},
    {value: 'HEAD', label: 'HEAD'},
    {value: 'OPTIONS', label: 'OPTIONS'},
];
export default class MakeHTTPCallCPE extends LightningElement {

    @track inputValues = {};

    @api inputVariables;
    testResult;
    labels = {
        urlLabel,
        Timeout_in_ms,
        HTTP_Method,
        Specify_Params,
        Add_Param,
        Specify_Headers,
        Add_Header,
        Body_Label,
        Compress_Request_body_to_gzip,
        Request_Body_as_Blob,
        Test_Callout,
        Response_Result,
        Error_Message,
        Status,
        Status_code,
        Make_HTTP_Call
    }
    get methodList() {
        return METHOD_LIST;
    }

    get url() {
        //return this.inputValues['Endpoint'];
        const param = this.inputVariables.find(({ name }) => name === 'Endpoint');
        return param && param.value;
    }

    get method() {
        //return this.inputValues['Method'];
        const param = this.inputVariables.find(({ name }) => name === 'Method');
        return param && param.value;
    }

    get headerList() {
        const param = this.inputVariables.find(({ name }) => name === 'Headers');
        return param && param.value;
    }

    get paramList() {
        const param = this.inputVariables.find(({ name }) => name === 'Params');
        return param && param.value;
    }

    get timeout() {
        const param = this.inputVariables.find(({ name }) => name === 'Timeout');
        return param && param.value;
    }

    get compressedGzip() {
        const param = this.inputVariables.find(({ name }) => name === 'Compressed_gzip');
        return param && param.value;
    }

    get bodyAsBlob() {
        const param = this.inputVariables.find(({ name }) => name === 'BodyAsBlob');
        return param && param.value;
    }

    get body() {
        const param = this.inputVariables.find(({ name }) => name === 'Body');
        return param && param.value;
    }

    

    dispatchFlowValueChangeEvent(id, newValue, newValueDataType) {
        const valueChangedEvent = new CustomEvent('configuration_editor_input_value_changed', {
            bubbles: true,
            cancelable: false,
            composed: true,
            detail: {
                name: id,
                newValue: newValue,
                newValueDataType: newValueDataType
            }
        });
        this.dispatchEvent(valueChangedEvent);
    }

    changeURL(event) {
        //this.inputValues['Endpoint'] = event.target.value;
        this.dispatchFlowValueChangeEvent('Endpoint', event.detail.value, 'String');
        
    }

    changeMethod(event) {
        //this.inputValues['Method'] = event.target.value;
        this.dispatchFlowValueChangeEvent('Method', event.detail.value, 'String');
    }

    changeHeaders(event) {
        this.dispatchFlowValueChangeEvent('Headers', event.detail.value, 'String');
    }

    changeParams(event) {
        this.dispatchFlowValueChangeEvent('Params', event.detail.value, 'String');
    }

    changeTimeout(event) {
        this.dispatchFlowValueChangeEvent('Timeout', Number(event.detail.value), 'Number');
    }

    changeCompressedGzip(event) {
        this.dispatchFlowValueChangeEvent('Compressed_gzip', event.detail.checked ? event.detail.checked : null, 'Boolean');
    }

    changeBodyAsBlob(event) {
        this.dispatchFlowValueChangeEvent('BodyAsBlob', event.detail.checked ? event.detail.checked : null, 'Boolean');
    }
    changeBody(event) {
        this.dispatchFlowValueChangeEvent('Body', event.detail.value, 'String');
    }

    makeTestCallout() {
        let request = {
            Method : this.method,
            Endpoint : this.url,
            Body : this.body,
            Timeout : this.timeout,
            Params : this.paramList,
            Headers : this.headerList,
            BodyAsBlob : this.bodyAsBlob,
            Compressed_gzip : this.compressedGzip

        };
        
        makeTestRESTCall( {
            'requestJSON' : JSON.stringify(request)
        }).then(result => {
            this.testResult = JSON.parse(result);

        }).catch(error => {
            console.error('error', error);
        });
    }


    
}