public without sharing class ContentDocumentLinkCreator {
    
    @InvocableMethod(label='Link Content Documents to Case' 
                    description='Creates ContentDocumentLinks to attach files to a Case')
    public static List<String> createContentDocumentLink(List<ContentDocLinkRequest> requests) {
        List<String> results = new List<String>();
        if (requests == null || requests.isEmpty()) {
            return results;
        }

        Set<Id> versionIds = new Set<Id>();
        for (ContentDocLinkRequest req : requests) {
            if (req.contentDocumentIds != null) {
                for (String id : req.contentDocumentIds) {
                    if (!String.isBlank(id) && id.startsWith('068')) {
                        versionIds.add(id);
                    }
                }
            }
        }

        Map<Id, Id> versionToDocMap = new Map<Id, Id>();
        if (!versionIds.isEmpty()) {
            for (ContentVersion cv : [
                SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :versionIds
            ]) {
                versionToDocMap.put(cv.Id, cv.ContentDocumentId);
            }
        }

        List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();

        for (ContentDocLinkRequest req : requests) {
            if (req.contentDocumentIds == null || req.contentDocumentIds.isEmpty()) {
                results.add('Error: contentDocumentIds is required and cannot be empty');
                continue;
            }

            if (String.isBlank(req.linkedEntityId)) {
                results.add('Error: linkedEntityId is required');
                continue;
            }

            String shareType = String.isBlank(req.shareType) ? 'V' : req.shareType;
            String visibility = String.isBlank(req.visibility) ? 'AllUsers' : req.visibility;

            for (String inputId : req.contentDocumentIds) {
                if (String.isBlank(inputId)) continue;

                String docId = inputId.startsWith('068') ? String.valueOf(versionToDocMap.get(inputId)) : inputId;

                if (String.isBlank(docId)) {
                    results.add('Error: Could not resolve ContentDocumentId from ' + inputId);
                    continue;
                }

                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = docId;
                cdl.LinkedEntityId = req.linkedEntityId;
                cdl.ShareType = shareType;
                cdl.Visibility = visibility;
                linksToInsert.add(cdl);
            }
        }

        for (ContentDocumentLink cdl : linksToInsert) {
            try {
                insert cdl;
                results.add(cdl.Id);
            } catch (Exception e) {
                results.add('Error: ' + e.getMessage());
            }
        }

        return results;
    }

    public class ContentDocLinkRequest {
        @InvocableVariable(required=true)
        public List<String> contentDocumentIds;

        @InvocableVariable(required=true)
        public String linkedEntityId;

        @InvocableVariable
        public String shareType;

        @InvocableVariable
        public String visibility;
    }
}