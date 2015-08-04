package edu.mit.kc.protocol.service;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionMapping;
import org.kuali.kra.irb.ProtocolForm;
import org.kuali.kra.protocol.ProtocolBase;


public interface MitProtocolMigrationService {

    public void createDocumentForMigratedProtocol(ProtocolBase protocol) throws Exception;
    
    public boolean createDocumentForMigratedProtocolAndRoute(ActionMapping mapping, HttpServletRequest request, HttpServletResponse response, ProtocolForm protocolForm, String docIdRequestParameter) throws Exception;

}
