@isTest
public class QuipTest {
    
    class QuipAPIMock implements StubProvider {

        private Map<String, ThreadResponse> threads = new Map<String, ThreadResponse>();

        private Map<String, List<List<Object>>> methodCalls;

        public QuipAPIMock(Map<String, List<List<Object>>> methodCalls) {
            this.methodCalls = methodCalls;
            ThreadResponse response = new ThreadResponse();
            ThreadResponse.Thread thread = new ThreadResponse.Thread();
            thread.id = 'Thread000001';
            thread.type = 'document';
            thread.title = '01';
            response.thread = thread;
            response.html = '<table title="Sheet1"><tbody><tr id="1"><td id="1-1"><span>Text</span></td></tr></tbody></table>';
            threads.put(thread.id, response);

            
            response = new ThreadResponse();
            thread = new ThreadResponse.Thread();
            thread.id = 'Thread000002';
            thread.type = 'document';
            thread.title = '02';
            response.thread = thread;
            response.html = '<table title="Sheet2"><tbody><tr id="1"><td id="1-1"><span>Text</span></td></tr></tbody></table>';
            threads.put(thread.id, response);
        }

        public Object handleMethodCall(
            Object stubbedObject, 
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs) {
            if (methodCalls != null) {
                List<List<Object>> calls = methodCalls.get(stubbedMethodName);
                if (calls == null) {
                    calls = new List<List<Object>>();
                    methodCalls.put(stubbedMethodName, calls);
                }
                calls.add(new List<Object>(listOfArgs));
            }
            if (stubbedMethodName == 'likeId') {
                String idOrName = listOfArgs[0].toString();
                if (idOrName.length() == 12) {
                    return true;
                }
                return false;
            }
            if (stubbedMethodName == 'getThread') {
                String id = listOfArgs[0].toString();
                return threads.get(id);
            }
            if (stubbedMethodName == 'getThreadList') {
                List<String> idList = (List<String>)listOfArgs[0];
                ThreadListResponse response = new ThreadListResponse();
                for (String id : idList) {
                    response.threads.add(threads.get(id));
                }
                return response;
            }
            if (stubbedMethodName == 'getCurrentUser') {
                UserResponse user = new UserResponse();
                user.starred_folder_id = 'Folder000001';
                user.desktop_folder_id = 'Folder000001';
                user.private_folder_id = 'Folder000001';
                user.shared_folder_ids.add('Folder000001');
                user.group_folder_ids.add('Folder000001');
                return user;
            }
            if (stubbedMethodName == 'getFolder') {
                System.debug('getFolder got the following arguments: ' + String.valueOf(listOfArgs));
                String id = listOfArgs[0].toString();
                if (id == 'Folder000001') {
                    FolderResponse response = new FolderResponse();
                    FolderResponse.Folder folder = new FolderResponse.Folder();
                    folder.id = 'Folder000001';
                    folder.title = 'folder';
                    response.folder = folder;
                    FolderResponse.ThreadOrFolder thread = new FolderResponse.ThreadOrFolder();
                    thread.thread_id = 'Thread000001';
                    response.children.add(thread);
                    FolderResponse.ThreadOrFolder subFolder = new FolderResponse.ThreadOrFolder();
                    subFolder.folder_id = 'Folder000002';                    
                    response.children.add(subFolder);
                    return response;
                }
                if (id == 'Folder000002') {
                    FolderResponse response = new FolderResponse();
                    FolderResponse.Folder folder = new FolderResponse.Folder();
                    folder.id = 'Folder000002';
                    folder.title = 'folder';
                    response.folder = folder;
                    FolderResponse.ThreadOrFolder thread = new FolderResponse.ThreadOrFolder();
                    thread.thread_id = 'Thread000002';
                    response.children.add(thread);
                    return response;
                }
                System.debug('Unhandled arguments for method: ' + stubbedMethodName);
                return null;
            }
            if (stubbedMethodName == 'editDocument') {
                //(thread.id, value, sectionId, location)
                String threadId = listOfArgs[0].toString();
                if (threadId == 'UpdateCell') {
                    ThreadResponse response = new ThreadResponse();
                    ThreadResponse.Thread thread = new ThreadResponse.Thread();
                    thread.id = 'UpdateCell';
                    thread.title = 'Title';
                    thread.type = 'spreadsheet';
                    response.thread = thread;
                    response.html = '<table title="Title"><tbody><tr id="row0"><td id="row0-col0"><span>Test</span></td></tr></tbody></table>';
                    return response;
                }
                if (threadId == 'AddRow') {
                    ThreadResponse response = new ThreadResponse();
                    ThreadResponse.Thread thread = new ThreadResponse.Thread();
                    thread.id = 'AddRow';
                    thread.title = 'Title';
                    thread.type = 'spreadsheet';
                    response.thread = thread;
                    response.html = '<table title="Title"><tbody><tr id="row0"><td id="row0-col0"><span>Test</span></td></tr></tbody></table>';
                    return response;
                }
                System.debug('Unhandled arguments for method: ' + stubbedMethodName);
                return null;
            }
            if (stubbedMethodName == 'createDocument') {
                ThreadResponse response = new ThreadResponse();
                ThreadResponse.Thread thread = new ThreadResponse.Thread();
                thread.id = 'newDocument';
                thread.title = 'newDocument';
                thread.type = 'document';
                response.thread = thread;
                response.html = '<table title="Title"><tbody><tr id="row0"><td id="row0-col0"><span>Test</span></td></tr></tbody></table>';
                return response;                
            }

            System.debug('Unhandled method call: ' + stubbedMethodName);
            return null;
        }
    }

    @isTest
    public static void findThread_ThrowsExceptionIfIdOrNameIsEmpty() {
        IQuipAPI api = (IQuipAPI)Test.createStub(IQuipAPI.class, new QuipAPIMock(null));
        Quip quip = new Quip(api);
        try {
            quip.findThread('');
            System.assert(false, 'Must throw exception');
        }
        catch (QuipException ex) {
            System.assertEquals('Id or Name can\'t be blank', ex.getMessage());
        }
    }

    @isTest
    public static void findThread_WhenIdIsPassed_CallsApi() {
        IQuipAPI api = (IQuipAPI)Test.createStub(IQuipAPI.class, new QuipAPIMock(null));
        Quip quip = new Quip(api);
        Thread thread = quip.findThread('Thread000001');
        System.assertEquals('Sheet1', thread.sheets[0].title);
    }

    @isTest
    public static void findThread_WhenNameIsPassedAndFileDoesntExist_Fails() {
        IQuipAPI api = (IQuipAPI)Test.createStub(IQuipAPI.class, new QuipAPIMock(null));
        Quip quip = new Quip(api);
        try { 
            quip.findThread('DoesntExist');
            System.assert(false, 'Must throw exception');
        }
        catch (QuipException ex) {
            System.assertEquals('File "DoesntExist" doesn\'t exist', ex.getMessage());
        }
    }

    @isTest
    public static void findThread_WhenNameIsPassedAndFileExists_ReturnsIt() {
        IQuipAPI api = (IQuipAPI)Test.createStub(IQuipAPI.class, new QuipAPIMock(null));
        Quip quip = new Quip(api);
        Thread thread = quip.findThread('01');
        System.assertEquals('Sheet1', thread.sheets[0].title);
    }

    @isTest
    public static void saveSpreadsheetData_WhenThreadIsNull_Fails() {
        Quip quip = new Quip(new QuipAPI());
        try {
            quip.saveSpreadsheetData(null, new ThreadSheet(), null);
            System.assert(false, 'Must fail');
        }
        catch (QuipException ex) {
            System.assertEquals('Thread is null', ex.getMessage());
        }
    }

    @isTest
    public static void saveSpreadsheetData_WhenThreadSheetIsNull_Fails() {
        Quip quip = new Quip(new QuipAPI());
        try {
            quip.saveSpreadsheetData(new Thread('1'), null, null);
            System.assert(false, 'Must fail');
        }
        catch (QuipException ex) {
            System.assertEquals('Sheet is null', ex.getMessage());
        }
    }

    @isTest
    public static void saveSpreadsheetData_WhenCellBelongsToTheSheet_UpdatesCell() {
        Map<String, List<List<Object>>> methodCalls = new Map<String, List<List<Object>>>();
        IQuipAPI api = (IQuipAPI)Test.createStub(IQuipAPI.class, new QuipAPIMock(methodCalls));
        Quip quip = new Quip(api);
        Thread thread = new Thread('UpdateCell');
        ThreadSheet sheet = new ThreadSheet();
        sheet.title = 'Title';
        thread.sheets.add(sheet);
        ThreadRow row = new ThreadRow('row0');
        sheet.rows.add(row);
        ThreadCell cell = new ThreadCell(Address.parse('A1'), 'row0-col0', 'Test');
        row.cells.add(cell);
        quip.saveSpreadsheetData(thread, sheet, new List<ThreadCell> { cell });
        List<List<Object>> calls = methodCalls.get('editDocument');
        System.assert(calls != null, 'editDocument method was not called');
        List<Object> args = calls[0];
        String threadId = args[0].toString();
        String value = args[1].toString();
        String sectionId = args[2].toString();
        SectionLocation location = (SectionLocation)args[3];
        System.assertEquals('UpdateCell', threadId, 'Incorrect thread Id');
        System.assertEquals('Test', value, 'Incorrect content');
        System.assertEquals('row0-col0', sectionId, 'Incorrect cell Id');
        System.assertEquals(SectionLocation.REPLACE_SECTION, location);
    }

    @isTest
    public static void saveSpreadsheetData_WhenRowDoesntBelongToTheSheet_AddsRow() {
        Map<String, List<List<Object>>> methodCalls = new Map<String, List<List<Object>>>();
        IQuipAPI api = (IQuipAPI)Test.createStub(IQuipAPI.class, new QuipAPIMock(methodCalls));
        Quip quip = new Quip(api);
        Thread thread = new Thread('AddRow');
        ThreadSheet sheet = new ThreadSheet();
        sheet.title = 'Title';
        thread.sheets.add(sheet);
        ThreadRow row = new ThreadRow('row0');
        sheet.rows.add(row);
        row.cells.add(new ThreadCell(Address.parse('A1'), 'row0-col0', 'Test'));
        quip.saveSpreadsheetData(thread, sheet, new List<ThreadCell> { new ThreadCell(Address.parse('A3'), null, 'Test') });
        List<List<Object>> calls = methodCalls.get('editDocument');
        System.assert(calls != null, 'editDocument method was not called');
        List<Object> args = calls[0];
        String threadId = args[0].toString();
        String value = args[1].toString();
        String sectionId = args[2].toString();
        SectionLocation location = (SectionLocation)args[3];
        System.assertEquals('AddRow', threadId, 'Incorrect thread Id');
        System.assertEquals('<tr></tr><tr><td>Test</td></tr>', value, 'Incorrect content');
        System.assertEquals('row0', sectionId, 'Incorrect cell Id');
        System.assertEquals(SectionLocation.AFTER_SECTION, location);
    }

    @isTest
    public static void saveSpreadsheetData_WhenColumnDoesntBelongToTheSheet_ThrowsException() {
        Quip quip = new Quip(new QuipAPI());
        try { 
            Thread thread = new Thread('AddCol');
            ThreadSheet sheet = new ThreadSheet();
            sheet.title = 'Title';
            thread.sheets.add(sheet);
            ThreadRow row = new ThreadRow('row0');
            sheet.rows.add(row);
            row.cells.add(new ThreadCell(Address.parse('A1'), 'row0-col0', 'Test'));
            quip.saveSpreadsheetData(thread, sheet, new List<ThreadCell> { new ThreadCell(Address.parse('C1'), null, 'Test') });
            System.assert(false, 'Must throw exception');
        }
        catch (QuipException ex) {
            System.assertEquals('The cell "C1" doesn\'t belong to the spreadsheet. Add it manually and try again', ex.getMessage());
        }
    }

    @isTest
    public static void cloneThread_findsAndClonesThread() {
        Map<String, List<List<Object>>> methodCalls = new Map<String, List<List<Object>>>();
        IQuipAPI api = (IQuipAPI)Test.createStub(IQuipAPI.class, new QuipAPIMock(methodCalls));
        Quip quip = new Quip(api);
        Thread copy = quip.cloneThread('Thread000001', 'newDocument');
        //createDocument(String title, String content, String type,  List<String> usersAndFolders);
        List<List<Object>> calls = methodCalls.get('createDocument');
        System.assert(calls != null, 'createDocument method was not called');
        List<Object> args = calls[0];
        String title = args[0].toString();
        String content = args[1].toString();
        String type = args[2].toString();
        List<String> usersAndFolders = (List<String>)args[3];
        System.assertEquals('newDocument', title);
        System.assertEquals('<table title="Sheet1"><tbody><tr id="1"><td id="1-1"><span>Text</span></td></tr></tbody></table>', content);
        System.assertEquals('document', type);
        System.assertEquals('Folder000001', usersAndFolders[0]);
    }
}