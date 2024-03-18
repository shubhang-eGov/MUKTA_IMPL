package org.egov.works.util;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.jayway.jsonpath.JsonPath;
import digit.models.coremodels.RequestInfoWrapper;
import lombok.extern.slf4j.Slf4j;
import org.egov.common.contract.request.RequestInfo;
import org.egov.tracer.model.CustomException;
import org.egov.works.config.NotificationServiceConfiguration;
import org.egov.works.models.ContractResponse;
import org.egov.works.models.EstimateResponse;
import org.egov.works.repository.ServiceRequestRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;
import static org.egov.works.config.Constants.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
@Slf4j
public class MeasurementServiceUtil {

    @Autowired
    private NotificationServiceConfiguration config;
    @Autowired
    private ServiceRequestRepository restRepo;
    @Autowired
    private ObjectMapper mapper;

    public String getProjectNumber(RequestInfo requestInfo, String tenantId, String referenceId) {
        String estimateId = getEstimateId(requestInfo, tenantId, referenceId);
        String projectId = getProjectId(requestInfo, tenantId, estimateId);
        return getProjectDetails(requestInfo, tenantId, projectId);
    }

    private String getEstimateId(RequestInfo requestInfo, String tenantId, String contractNumber) {
        StringBuilder contractSearchUri = new StringBuilder(config.getContractHost()).append(config.getContractEndpoint());
        ObjectNode contractSearchReq = mapper.createObjectNode();

        contractSearchReq.putPOJO("RequestInfo", requestInfo);
        contractSearchReq.put("tenantId", tenantId);
        contractSearchReq.put("contractNumber", contractNumber);

        Object response = restRepo.fetchResult(contractSearchUri, contractSearchReq);
        ContractResponse contractResponse;
        try {
            contractResponse = mapper.convertValue(response, ContractResponse.class);
        } catch (Exception e) {
            throw new CustomException(CONVERSION_ERROR_CODE, CONVERSION_ERROR_MSG);
        }
        return contractResponse.getContracts().get(0).getLineItems().get(0).getEstimateId();

    }
    private String getProjectId(RequestInfo requestInfo, String tenantId, String estimateId) {
        String estimateSearchUri = config.getEstimateHost()+config.getEstimateEndpoint();
        UriComponentsBuilder uri = UriComponentsBuilder.fromUriString(estimateSearchUri);
        uri.queryParam("tenantId", tenantId);
        uri.queryParam("ids", estimateId);
        StringBuilder url = new StringBuilder(uri.toUriString());

        RequestInfoWrapper requestInfoWrapper = RequestInfoWrapper.builder().requestInfo(requestInfo).build();
        Object response = restRepo.fetchResult(url, requestInfoWrapper);
        EstimateResponse estimateResponse;
        try {
            estimateResponse = mapper.convertValue(response, EstimateResponse.class);
        } catch (Exception e) {
            throw new CustomException(CONVERSION_ERROR_CODE, CONVERSION_ERROR_MSG);
        }
        return estimateResponse.getEstimates().get(0).getProjectId();
    }

    private String getProjectDetails(RequestInfo requestInfo, String tenantId, String projectId) {
        log.info("ProjectUtil::getProjectDetails");
        String projectSearchUri = config.getWorksProjectManagementSystemHost()+config.getWorksProjectManagementSystemPath();
        UriComponentsBuilder uri = UriComponentsBuilder.fromUriString(projectSearchUri);
        uri.queryParam("tenantId", tenantId);
        uri.queryParam("offset", "0");
        uri.queryParam("limit", "1");
        StringBuilder url = new StringBuilder(uri.toUriString());

        //created the project search request body
        ObjectNode projectSearchReqNode = mapper.createObjectNode();
        ArrayNode projectArrayNode = mapper.createArrayNode();

        ObjectNode projectObjNode = mapper.createObjectNode();
        projectObjNode.put("id", projectId);
        projectObjNode.put("tenantId", tenantId);

        projectArrayNode.add(projectObjNode);

        projectSearchReqNode.putPOJO("RequestInfo", requestInfo);
        projectSearchReqNode.putPOJO("Projects", projectArrayNode);

        log.info("ProjectUtil::search project request -> {}",projectSearchReqNode);
        Object projectRes = restRepo.fetchResult(url, projectSearchReqNode);

        List<String> projectNumber = new ArrayList<>();
        try {
            projectNumber = JsonPath.read(projectRes, PROJECT_NUMBER);
        } catch (Exception e) {
            throw new CustomException(PARSING_ERROR_CODE, PARSING_ERROR_MSG);
        }
        return projectNumber.get(0);
    }

    public String getEmployeeMobileNumber(RequestInfo requestInfo, String tenantId, String uuid) {
        StringBuilder url = getHRMSURIWithUUid(tenantId, uuid);
        RequestInfoWrapper requestInfoWrapper = RequestInfoWrapper.builder().requestInfo(requestInfo).build();
        Object res = restRepo.fetchResult(url, requestInfoWrapper);
        List<String> mobileNumber = null;
        try {
            mobileNumber = JsonPath.read(res, HRMS_USER_MOBILE_NO);
        } catch (Exception e) {
            throw new CustomException(PARSING_ERROR_CODE, PARSING_ERROR_MSG);
        }
        return mobileNumber.get(0);
    }
    private StringBuilder getHRMSURIWithUUid(String tenantId, String employeeUuid) {

        StringBuilder builder = new StringBuilder(config.getHrmsHost());
        builder.append(config.getHrmsEndPoint());
        builder.append("?tenantId=");
        builder.append(tenantId);
        builder.append("&uuids=");
        builder.append(employeeUuid);

        return builder;
    }

    public Map<String, Map<String, String>> getLocalisedMessages(RequestInfo requestInfo, String rootTenantId, String locale, String module) {
        Map<String, Map<String, String>> localizedMessageMap = new HashMap<>();
        Map<String, String> mapOfCodesAndMessages = new HashMap<>();
        StringBuilder uri = new StringBuilder();
        RequestInfoWrapper requestInfoWrapper = new RequestInfoWrapper();
        requestInfoWrapper.setRequestInfo(requestInfo);
        uri.append(config.getLocalizationHost()).append(config.getLocalizationContextPath())
                .append(config.getLocalizationSearchEndpoint()).append("?tenantId=" + rootTenantId)
                .append("&module=" + module).append("&locale=" + locale);
        List<String> codes = null;
        List<String> messages = null;
        Object result = null;
        try {
            result = restRepo.fetchResult(uri, requestInfoWrapper);
            codes = JsonPath.read(result, LOCALIZATION_CODES_JSONPATH);
            messages = JsonPath.read(result, MSGS_JSONPATH);
        } catch (Exception e) {
            log.error("Exception while fetching from localization: " + e);
        }
        if (null != result) {
            for (int i = 0; i < codes.size(); i++) {
                mapOfCodesAndMessages.put(codes.get(i), messages.get(i));
            }
            localizedMessageMap.put(locale + "|" + rootTenantId, mapOfCodesAndMessages);
        }

        return localizedMessageMap;
    }

}
