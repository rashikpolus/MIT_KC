package edu.mit.kc.irb.actions.amendrenew;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.kuali.kra.irb.actions.amendrenew.ProtocolAmendRenewServiceImpl;
import org.kuali.kra.protocol.ProtocolBase;
import org.kuali.kra.protocol.ProtocolDocumentBase;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;

import edu.mit.kc.protocol.service.MitProtocolMigrationService;

public class MitProtocolAmendRenewServiceImpl extends ProtocolAmendRenewServiceImpl {

    @Autowired
    @Qualifier("mitProtocolMigrationService")
    private MitProtocolMigrationService mitProtocolMigrationService;
    
	@Override
    public Collection<ProtocolBase> getAmendments(String protocolNumber) throws Exception {
        List<ProtocolBase> amendments = new ArrayList<ProtocolBase>();
        Collection<ProtocolBase> protocols = (Collection<ProtocolBase>) kraLookupDao.findCollectionUsingWildCard(getProtocolBOClassHook(), PROTOCOL_NUMBER, protocolNumber + AMEND_ID + "%", true);
        for (ProtocolBase protocol : protocols) {
           	if (protocol.getProtocolDocument().getDocumentNumber().startsWith("MP")) { 
              	 getMitProtocolMigrationService().createDocumentForMigratedProtocol(protocol); 
              	 amendments.add(protocol); 
          	} 
            ProtocolDocumentBase protocolDocument = (ProtocolDocumentBase) documentService.getByDocumentHeaderId(protocol.getProtocolDocument().getDocumentNumber());
            amendments.add(protocolDocument.getProtocol());
        }
        return amendments;
    }

    public Collection<ProtocolBase> getRenewals(String protocolNumber) throws Exception {
        List<ProtocolBase> renewals = new ArrayList<ProtocolBase>();
        Collection<ProtocolBase> protocols = (Collection<ProtocolBase>) kraLookupDao.findCollectionUsingWildCard(getProtocolBOClassHook(), PROTOCOL_NUMBER, protocolNumber + RENEW_ID + "%", true);
        for (ProtocolBase protocol : protocols) {
           	if (protocol.getProtocolDocument().getDocumentNumber().startsWith("MP")) { 
            	 getMitProtocolMigrationService().createDocumentForMigratedProtocol(protocol); 
              	renewals.add(protocol); 
         	} 
            ProtocolDocumentBase protocolDocument = (ProtocolDocumentBase) documentService.getByDocumentHeaderId(protocol.getProtocolDocument().getDocumentNumber());
            renewals.add(protocolDocument.getProtocol());
        }
        return renewals;
    }
	
	public MitProtocolMigrationService getMitProtocolMigrationService() {
		return mitProtocolMigrationService;
	}

	public void setMitProtocolMigrationService(
			MitProtocolMigrationService mitProtocolMigrationService) {
		this.mitProtocolMigrationService = mitProtocolMigrationService;
	}

}
