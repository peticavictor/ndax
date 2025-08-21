@isTest
private class ContentDocumentLinkCreatorTest {
    @isTest
    static void createContentDocumentLinkTestAllCases() {
        Case testCase = new Case(Subject = 'Main Case');
        insert testCase;

        ContentVersion cv = new ContentVersion(
            Title = 'TestFile',
            PathOnClient = 'file.txt',
            VersionData = Blob.valueOf('file content')
        );
        insert cv;
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        ContentVersion cv2 = new ContentVersion(
    		Title = 'TestFile2',
    		PathOnClient = 'file2.txt',
    		VersionData = Blob.valueOf('another content')
		);
		insert cv2;
		cv2 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv2.Id];

        ContentDocumentLinkCreator.ContentDocLinkRequest req1 = new ContentDocumentLinkCreator.ContentDocLinkRequest();
        req1.contentDocumentIds = new List<String>{cv.Id};
        req1.linkedEntityId = testCase.Id;
        req1.shareType = 'V';
        req1.visibility = 'AllUsers';
        
        ContentDocumentLinkCreator.ContentDocLinkRequest req2 = new ContentDocumentLinkCreator.ContentDocLinkRequest();
		req2.contentDocumentIds = new List<String>{cv2.ContentDocumentId};
		req2.linkedEntityId = testCase.Id;

        ContentDocumentLinkCreator.ContentDocLinkRequest req3 = new ContentDocumentLinkCreator.ContentDocLinkRequest();
        req3.contentDocumentIds = null;
        req3.linkedEntityId = testCase.Id;

        ContentDocumentLinkCreator.ContentDocLinkRequest req4 = new ContentDocumentLinkCreator.ContentDocLinkRequest();
        req4.contentDocumentIds = new List<String>();
        req4.linkedEntityId = testCase.Id;

        ContentDocumentLinkCreator.ContentDocLinkRequest req5 = new ContentDocumentLinkCreator.ContentDocLinkRequest();
        req5.contentDocumentIds = new List<String>{cv.ContentDocumentId};
        req5.linkedEntityId = null;

        ContentDocumentLinkCreator.ContentDocLinkRequest req6 = new ContentDocumentLinkCreator.ContentDocLinkRequest();
        req6.contentDocumentIds = new List<String>{'068000000000000'};
        req6.linkedEntityId = testCase.Id;

        Test.startTest();
        List<String> results = ContentDocumentLinkCreator.createContentDocumentLink(
            new List<ContentDocumentLinkCreator.ContentDocLinkRequest>{
                req1, req2, req3, req4, req5, req6
            }
        );
        Test.stopTest();

        System.assertEquals(6, results.size());
        Integer successCount = 0;
        for (String res : results) {
            if (!res.startsWith('Error')) successCount++;
        }
        System.assertEquals(2, successCount);
    }
}