import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

const supabaseUrl = 'https://sugqehxmbugoplqlhtlp.supabase.co';
const supabasePublishableKey = 'sb_publishable_QSIO-if22lK4-6P-OUSjkQ_LvjIcviO';
const navy = Color(0xFF02060E), navy2 = Color(0xFF06142B), blue = Color(0xFF0356C5), blue2 = Color(0xFF1976E8), gold = Color(0xFFD6B56A), text = Color(0xFFF4F8FF), muted = Color(0xFFAFC7E8);
final supabase = Supabase.instance.client;

Future<void> main() async { WidgetsFlutterBinding.ensureInitialized(); await Supabase.initialize(url: supabaseUrl, publishableKey: supabasePublishableKey); runApp(const MizanApp()); }

class MizanApp extends StatelessWidget { const MizanApp({super.key}); @override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,title:'ميزان',theme:ThemeData(useMaterial3:true,scaffoldBackgroundColor:navy,colorScheme:ColorScheme.fromSeed(seedColor:blue,brightness:Brightness.dark)),home:const AuthGate()); }

class AuthGate extends StatelessWidget { const AuthGate({super.key}); @override Widget build(BuildContext c){ final u=supabase.auth.currentUser; if(u==null)return const LoginPage(); return FutureBuilder<List<Map<String,dynamic>>>(future:supabase.from('profiles').select('role,full_name,phone').eq('id',u.id).limit(1),builder:(c,s){if(s.connectionState==ConnectionState.waiting)return const _Loading(); if(s.hasError)return const LoginPage(); final role=(s.data??[]).isNotEmpty?s.data!.first['role']:'client'; return role=='lawyer'||role=='admin'?const StaffShell():const ClientShell();}); } }

class LoginPage extends StatefulWidget{const LoginPage({super.key});@override State<LoginPage> createState()=>_LoginPageState();}
class _LoginPageState extends State<LoginPage>{final email=TextEditingController(),password=TextEditingController(),name=TextEditingController();bool loading=false,signup=false;Future<void> submit()async{if(email.text.trim().isEmpty||password.text.length<6){_snack(context,'اكتب بريدًا صحيحًا وكلمة مرور 6 أحرف على الأقل');return;}setState(()=>loading=true);try{if(signup){final r=await supabase.auth.signUp(email:email.text.trim(),password:password.text, data:{'full_name':name.text.trim()});if(r.session==null)_snack(context,'تم إنشاء الحساب. راجع البريد إذا كان تأكيد البريد مفعّلًا.');}else{await supabase.auth.signInWithPassword(email:email.text.trim(),password:password.text);}if(mounted&&supabase.auth.currentSession!=null)Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(_)=>const AuthGate()),(_)=>false);}on AuthException catch(e){_snack(context,e.message);}catch(e){_snack(context,'حدث خطأ في الاتصال بقاعدة البيانات');}finally{if(mounted)setState(()=>loading=false);}}@override Widget build(BuildContext c)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(body:Container(decoration:const BoxDecoration(gradient:LinearGradient(colors:[navy2,navy],begin:Alignment.topCenter,end:Alignment.bottomCenter)),child:SafeArea(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:Column(children:[const SizedBox(height:45),Container(width:88,height:88,decoration:BoxDecoration(shape:BoxShape.circle,color:gold.withValues(alpha: .12),border:Border.all(color:gold)),child:const Icon(Icons.balance,color:gold,size:46)),const SizedBox(height:18),const Text('ميزان',style:TextStyle(color:text,fontSize:38,fontWeight:FontWeight.w900)),const Text('مكتب المستشار فريد حسام عبدالهادي',style:TextStyle(color:muted)),const SizedBox(height:35),if(signup)...[_field(name,'اسم العميل',Icons.person_outline),const SizedBox(height:12)],_field(email,'البريد الإلكتروني',Icons.email_outlined),const SizedBox(height:12),_field(password,'كلمة المرور',Icons.lock_outline,obscure:true),const SizedBox(height:20),SizedBox(width:double.infinity,height:54,child:ElevatedButton.icon(onPressed:loading?null:submit,icon:loading?const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2)):Icon(signup?Icons.person_add:Icons.login),label:Text(signup?'إنشاء حساب عميل':'تسجيل الدخول'),style:ElevatedButton.styleFrom(backgroundColor:blue,foregroundColor:Colors.white))),TextButton(onPressed:loading?null:()=>setState(()=>signup=!signup),child:Text(signup?'لديك حساب؟ تسجيل الدخول':'ليس لديك حساب؟ إنشاء حساب'))])))));}Widget _field(TextEditingController x,String h,IconData i,{bool obscure=false})=>TextField(controller:x,obscureText:obscure,style:const TextStyle(color:text),decoration:InputDecoration(hintText:h,hintStyle:const TextStyle(color:muted),prefixIcon:Icon(i,color:muted),filled:true,fillColor:Colors.white12,border:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(16)))));}

class ClientShell extends StatefulWidget{const ClientShell({super.key});@override State<ClientShell> createState()=>_ClientShellState();}
class _ClientShellState extends State<ClientShell>{int i=0;final pages=const[ClientHome(),ClientCases(),ClientAppointments(),ClientNotifications(),ServicesPage(),ProfilePage()];@override Widget build(BuildContext c)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(body:pages[i],bottomNavigationBar:NavigationBar(selectedIndex:i,onDestinationSelected:(v)=>setState(()=>i=v),backgroundColor:navy2,indicatorColor:blue.withValues(alpha: .25),destinations:const[NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home),label:'الرئيسية'),NavigationDestination(icon:Icon(Icons.folder_outlined),selectedIcon:Icon(Icons.folder),label:'القضايا'),NavigationDestination(icon:Icon(Icons.calendar_month_outlined),selectedIcon:Icon(Icons.calendar_month),label:'المواعيد'),NavigationDestination(icon:Icon(Icons.notifications_none),selectedIcon:Icon(Icons.notifications),label:'الإشعارات'),NavigationDestination(icon:Icon(Icons.gavel_outlined),selectedIcon:Icon(Icons.gavel),label:'الخدمات'),NavigationDestination(icon:Icon(Icons.person_outline),selectedIcon:Icon(Icons.person),label:'حسابي')])));}

class StaffShell extends StatefulWidget{const StaffShell({super.key});@override State<StaffShell> createState()=>_StaffShellState();}
class _StaffShellState extends State<StaffShell>{int i=0;final pages=const[StaffDashboard(),StaffClientsPage(),StaffCasesPage(),StaffAppointmentsPage(),ProfilePage()];@override Widget build(BuildContext c)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(body:pages[i],bottomNavigationBar:NavigationBar(selectedIndex:i,onDestinationSelected:(v)=>setState(()=>i=v),backgroundColor:navy2,indicatorColor:gold.withValues(alpha: .22),destinations:const[NavigationDestination(icon:Icon(Icons.dashboard_outlined),selectedIcon:Icon(Icons.dashboard),label:'المكتب'),NavigationDestination(icon:Icon(Icons.people_outline),selectedIcon:Icon(Icons.people),label:'العملاء'),NavigationDestination(icon:Icon(Icons.folder_outlined),selectedIcon:Icon(Icons.folder),label:'القضايا'),NavigationDestination(icon:Icon(Icons.event_outlined),selectedIcon:Icon(Icons.event),label:'الجلسات'),NavigationDestination(icon:Icon(Icons.person_outline),selectedIcon:Icon(Icons.person),label:'حسابي')])));}

class StaffDashboard extends StatelessWidget{const StaffDashboard({super.key});Future<List<dynamic>> _counts()=>Future.wait([supabase.from('profiles').select('id'),supabase.from('cases').select('id'),supabase.from('appointments').select('id'),supabase.from('consultation_requests').select('id')]);@override Widget build(BuildContext c)=>_page(child:FutureBuilder<List<dynamic>>(future:_counts(),builder:(c,s){final x=s.data??[[],[],[],[]];return ListView(padding:const EdgeInsets.all(18),children:[const Text('لوحة تحكم المكتب',style:TextStyle(color:text,fontSize:27,fontWeight:FontWeight.w900)),const SizedBox(height:8),const Text('إدارة العملاء والقضايا والجلسات من مكان واحد',style:TextStyle(color:muted)),const SizedBox(height:18),Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF0D4FA8),Color(0xFF061A38)]),borderRadius:BorderRadius.all(Radius.circular(24))),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('مكتب فريد حسام عبدالهادي',style:TextStyle(color:gold,fontWeight:FontWeight.bold)),SizedBox(height:8),Text('مرحبًا بك في لوحة المكتب القانونية',style:TextStyle(color:text,fontSize:22,fontWeight:FontWeight.w900))])),const SizedBox(height:18),Row(children:[Expanded(child:_stat('العملاء',x[0].length.toString(),Icons.people)),const SizedBox(width:8),Expanded(child:_stat('القضايا',x[1].length.toString(),Icons.folder)),const SizedBox(width:8),Expanded(child:_stat('الجلسات',x[2].length.toString(),Icons.event))]),const SizedBox(height:12),_action(c,'إضافة قضية',Icons.add_business,()=>_showAddCase(c)),_action(c,'إضافة جلسة',Icons.event_available,()=>_showAddAppointment(c)),_action(c,'إرسال إشعار',Icons.notifications_active,()=>_showNotification(c))];}));}

class StaffClientsPage extends StatelessWidget{const StaffClientsPage({super.key});@override Widget build(BuildContext c)=>_page(child:FutureBuilder<List<Map<String,dynamic>>>(future:supabase.from('profiles').select('id,full_name,phone,role').order('created_at',ascending:false),builder:(c,s){if(s.connectionState==ConnectionState.waiting)return const _Loading();if(s.hasError)return _error('تعذر تحميل العملاء');final rows=(s.data??[]).where((r)=>(r['role']??'client')=='client').toList();return ListView(padding:const EdgeInsets.all(18),children:[const Text('العملاء',style:TextStyle(color:text,fontSize:26,fontWeight:FontWeight.w900)),const SizedBox(height:14),if(rows.isEmpty)const _Empty(text:'لا يوجد عملاء مسجلون حتى الآن'),...rows.map((r)=>_card(child:ListTile(leading:const CircleAvatar(backgroundColor:blue,child:Icon(Icons.person,color:Colors.white)),title:Text((r['full_name']??'عميل').toString().isEmpty?'عميل':r['full_name'],style:const TextStyle(color:text,fontWeight:FontWeight.bold)),subtitle:Text(r['phone']??'لا يوجد رقم هاتف',style:const TextStyle(color:muted)),trailing:const Icon(Icons.chevron_left,color:muted))))]);}));}

class StaffCasesPage extends StatefulWidget{const StaffCasesPage({super.key});@override State<StaffCasesPage> createState()=>_StaffCasesPageState();}
class _StaffCasesPageState extends State<StaffCasesPage>{@override Widget build(BuildContext c)=>_page(child:FutureBuilder<List<Map<String,dynamic>>>(future:supabase.from('cases').select().order('created_at',ascending:false),builder:(c,s){if(s.connectionState==ConnectionState.waiting)return const _Loading();if(s.hasError)return _error('تعذر تحميل القضايا');final rows=s.data??[];return ListView(padding:const EdgeInsets.all(18),children:[Row(children:[const Expanded(child:Text('إدارة القضايا',style:TextStyle(color:text,fontSize:26,fontWeight:FontWeight.w900))),IconButton(onPressed:()=>_showAddCase(c),icon:const Icon(Icons.add_circle,color:gold,size:30))]),const SizedBox(height:10),if(rows.isEmpty)const _Empty(text:'لا توجد قضايا'),...rows.map((r)=>_caseTile(r))]);}));Widget _caseTile(Map<String,dynamic> r)=>_card(child:ListTile(leading:const Icon(Icons.folder,color:blue2,size:32),title:Text('قضية ${r['case_number']??''}',style:const TextStyle(color:text,fontWeight:FontWeight.bold)),subtitle:Text('${r['client_name']??''} • ${r['case_type']??''}',style:const TextStyle(color:muted)),trailing:IconButton(icon:const Icon(Icons.description_outlined,color:gold),onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>CaseDocumentsPage(caseId:r['id'].toString(),caseTitle:'قضية ${r['case_number']??''}'))))));}

class StaffAppointmentsPage extends StatelessWidget{const StaffAppointmentsPage({super.key});@override Widget build(BuildContext c)=>_page(child:FutureBuilder<List<Map<String,dynamic>>>(future:supabase.from('appointments').select().order('appointment_at'),builder:(c,s){if(s.connectionState==ConnectionState.waiting)return const _Loading();if(s.hasError)return _error('تعذر تحميل الجلسات');final rows=s.data??[];return ListView(padding:const EdgeInsets.all(18),children:[Row(children:[const Expanded(child:Text('إدارة الجلسات',style:TextStyle(color:text,fontSize:26,fontWeight:FontWeight.w900))),IconButton(onPressed:()=>_showAddAppointment(c),icon:const Icon(Icons.add_circle,color:gold,size:30))]),...rows.map((r)=>_card(child:ListTile(leading:const Icon(Icons.event,color:gold),title:Text(r['title']??'جلسة',style:const TextStyle(color:text,fontWeight:FontWeight.bold)),subtitle:Text(r['appointment_at']??'',style:const TextStyle(color:muted)))))]); }));}

class ClientHome extends StatelessWidget{const ClientHome({super.key});@override Widget build(BuildContext c)=>_page(child:FutureBuilder<List<dynamic>>(future:Future.wait([supabase.from('cases').select('id'),supabase.from('appointments').select('id'),supabase.from('notifications').select('id').eq('is_read',false)]),builder:(c,s){final x=s.data??[[],[],[]];return ListView(padding:const EdgeInsets.all(18),children:[const Text('مرحبًا بك في ميزان',style:TextStyle(color:text,fontSize:27,fontWeight:FontWeight.w900)),const SizedBox(height:8),const Text('تابع قضيتك ومواعيدك ومستنداتك بأمان',style:TextStyle(color:muted)),const SizedBox(height:20),Row(children:[Expanded(child:_stat('القضايا',x[0].length.toString(),Icons.folder)),const SizedBox(width:8),Expanded(child:_stat('المواعيد',x[1].length.toString(),Icons.event)),const SizedBox(width:8),Expanded(child:_stat('إشعارات',x[2].length.toString(),Icons.notifications))])]);}));}

class ClientCases extends StatelessWidget{const ClientCases({super.key});@override Widget build(BuildContext c)=>_page(child:FutureBuilder<List<Map<String,dynamic>>>(future:supabase.from('cases').select().order('created_at',ascending:false),builder:(c,s){if(s.connectionState==ConnectionState.waiting)return const _Loading();if(s.hasError)return _error('تعذر تحميل القضايا');final rows=s.data??[];return ListView(padding:const EdgeInsets.all(18),children:[const Text('قضاياي',style:TextStyle(color:text,fontSize:26,fontWeight:FontWeight.w900)),...rows.map((r)=>_card(child:ListTile(leading:const Icon(Icons.folder,color:blue2),title:Text('قضية ${r['case_number']??''}',style:const TextStyle(color:text,fontWeight:FontWeight.bold)),subtitle:Text('${r['case_type']??''} • ${r['status']??''}',style:const TextStyle(color:muted)),trailing:IconButton(icon:const Icon(Icons.description_outlined,color:gold),onPressed:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>CaseDocumentsPage(caseId:r['id'].toString(),caseTitle:'قضية ${r['case_number']??''}'))))))]);}));}
class ClientAppointments extends StatelessWidget{const ClientAppointments({super.key});@override Widget build(BuildContext c)=>_page(child:FutureBuilder<List<Map<String,dynamic>>>(future:supabase.from('appointments').select().order('appointment_at'),builder:(c,s){if(s.connectionState==ConnectionState.waiting)return const _Loading();final rows=s.data??[];return ListView(padding:const EdgeInsets.all(18),children:[const Text('مواعيدي',style:TextStyle(color:text,fontSize:26,fontWeight:FontWeight.w900)),...rows.map((r)=>_card(child:ListTile(leading:const Icon(Icons.event,color:gold),title:Text(r['title']??'جلسة',style:const TextStyle(color:text)),subtitle:Text(r['appointment_at']??'',style:const TextStyle(color:muted))))]);}));}

class ClientNotifications extends StatefulWidget {
  const ClientNotifications({super.key});
  @override State<ClientNotifications> createState()=>_ClientNotificationsState();
}
class _ClientNotificationsState extends State<ClientNotifications>{
  Future<void> _markRead(String id) async {
    await supabase.from('notifications').update({'is_read':true}).eq('id',id).eq('user_id',supabase.auth.currentUser!.id);
    if(mounted)setState((){});
  }
  @override Widget build(BuildContext c)=>_page(child:FutureBuilder<List<Map<String,dynamic>>>(
    future:supabase.from('notifications').select().eq('user_id',supabase.auth.currentUser!.id).order('created_at',ascending:false),
    builder:(c,s){
      if(s.connectionState==ConnectionState.waiting)return const _Loading();
      if(s.hasError)return _error('تعذر تحميل الإشعارات');
      final rows=s.data??[];
      return ListView(padding:const EdgeInsets.all(18),children:[
        const Text('الإشعارات',style:TextStyle(color:text,fontSize:26,fontWeight:FontWeight.w900)),
        const SizedBox(height:12),
        if(rows.isEmpty)const _Empty(text:'لا توجد إشعارات حاليًا'),
        ...rows.map((r)=>_card(child:ListTile(
          leading:Icon(r['is_read']==true?Icons.notifications_none:Icons.notifications_active,color:r['is_read']==true?muted:gold),
          title:Text(r['title']??'',style:const TextStyle(color:text,fontWeight:FontWeight.bold)),
          subtitle:Text(r['body']??'',style:const TextStyle(color:muted)),
          trailing:r['is_read']==true?null:IconButton(icon:const Icon(Icons.done,color:blue2),onPressed:()=>_markRead(r['id'].toString())),
        )))
      ]);
    }));
}

class CaseDocumentsPage extends StatefulWidget{
  final String caseId, caseTitle;
  const CaseDocumentsPage({super.key,required this.caseId,required this.caseTitle});
  @override State<CaseDocumentsPage> createState()=>_CaseDocumentsPageState();
}
class _CaseDocumentsPageState extends State<CaseDocumentsPage>{
  bool uploading=false;
  Future<void> _upload() async {
    try{
      setState(()=>uploading=true);
      final result=await FilePicker.platform.pickFiles(withData:true);
      if(result==null || result.files.single.bytes==null)return;
      final f=result.files.single;
      final uploader=supabase.auth.currentUser!.id;
      final caseRows=await supabase.from('cases').select('user_id').eq('id',widget.caseId).limit(1);
      if(caseRows.isEmpty) throw Exception('CASE_NOT_FOUND');
      final clientId=caseRows.first['user_id'].toString();
      final path='$clientId/${widget.caseId}/${DateTime.now().millisecondsSinceEpoch}_${f.name}';
      await supabase.storage.from('case-documents').uploadBinary(path,f.bytes!);
      await supabase.from('case_documents').insert({
        'case_id':widget.caseId,'user_id':clientId,'name':f.name,'storage_path':path,'uploaded_by':uploader
      });
      if(mounted)_snack(context,'تم رفع المستند بنجاح');
      if(mounted)setState((){});
    }catch(e){
      if(mounted)_snack(context,'تعذر رفع المستند. تأكد من إعداد Storage في Supabase');
    }finally{
      if(mounted)setState(()=>uploading=false);
    }
  }
  Future<void> _openDoc(Map<String,dynamic> row) async {
    try{
      final url=await supabase.storage.from('case-documents').createSignedUrl(row['storage_path'].toString(),3600);
      if(mounted)showDialog(context:context,builder:(_)=>AlertDialog(
        backgroundColor:navy2,
        title:Text(row['name']??'المستند',style:const TextStyle(color:text)),
        content:SelectableText(url,style:const TextStyle(color:muted)),
      ));
    }catch(e){if(mounted)_snack(context,'تعذر فتح المستند');}
  }
  @override Widget build(BuildContext c)=>_page(child:FutureBuilder<List<Map<String,dynamic>>>(
    future:supabase.from('case_documents').select().eq('case_id',widget.caseId).order('created_at',ascending:false),
    builder:(c,s){
      if(s.connectionState==ConnectionState.waiting)return const _Loading();
      if(s.hasError)return _error('تعذر تحميل المستندات');
      final rows=s.data??[];
      return ListView(padding:const EdgeInsets.all(18),children:[
        Row(children:[
          IconButton(onPressed:()=>Navigator.pop(c),icon:const Icon(Icons.arrow_back,color:text)),
          Expanded(child:Text(widget.caseTitle,style:const TextStyle(color:text,fontSize:22,fontWeight:FontWeight.w900))),
          IconButton(onPressed:uploading?null:_upload,icon:uploading?const SizedBox(width:22,height:22,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.upload_file,color:gold))
        ]),
        const SizedBox(height:8),
        if(rows.isEmpty)const _Empty(text:'لا توجد مستندات لهذه القضية'),
        ...rows.map((r)=>_card(child:ListTile(
          leading:const Icon(Icons.description,color:blue2),
          title:Text(r['name']??'مستند',style:const TextStyle(color:text)),
          subtitle:Text(r['created_at']??'',style:const TextStyle(color:muted,fontSize:11)),
          onTap:()=>_openDoc(r),
        )))
      ]);
    }));
}

class ServicesPage extends StatelessWidget{const ServicesPage({super.key});@override Widget build(BuildContext c)=>_page(child:FutureBuilder<List<Map<String,dynamic>>>(future:supabase.from('services').select().eq('is_active',true).order('sort_order'),builder:(c,s){if(s.connectionState==ConnectionState.waiting)return const _Loading();final rows=s.data??[];return GridView.builder(padding:const EdgeInsets.all(18),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:12,mainAxisSpacing:12,childAspectRatio:.9),itemCount:rows.length,itemBuilder:(_,i)=>_card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.gavel,color:blue2,size:34),const Spacer(),Text(rows[i]['name']??'',style:const TextStyle(color:text,fontWeight:FontWeight.w800)),const SizedBox(height:6),Text(rows[i]['description']??'',style:const TextStyle(color:muted,fontSize:11))]))));}));}
class ProfilePage extends StatelessWidget{const ProfilePage({super.key});@override Widget build(BuildContext c)=>_page(child:FutureBuilder<List<Map<String,dynamic>>>(future:supabase.from('profiles').select().eq('id',supabase.auth.currentUser!.id).limit(1),builder:(c,s){final p=(s.data??[]).isNotEmpty?s.data!.first:{};return ListView(padding:const EdgeInsets.all(18),children:[_card(child:ListTile(leading:const CircleAvatar(backgroundColor:gold,child:Icon(Icons.person,color:navy)),title:Text(p['full_name']??'المستخدم',style:const TextStyle(color:text,fontWeight:FontWeight.bold)),subtitle:Text('${supabase.auth.currentUser?.email??''}\nالصلاحية: ${p['role']??'client'}',style:const TextStyle(color:muted)))),const SizedBox(height:20),ListTile(onTap:()async{await supabase.auth.signOut();if(c.mounted)Navigator.pushAndRemoveUntil(c,MaterialPageRoute(builder:(_)=>const LoginPage()),(_)=>false);},leading:const Icon(Icons.logout,color:Colors.redAccent),title:const Text('تسجيل الخروج',style:TextStyle(color:Colors.redAccent)))]);}));}

Future<void> _showAddCase(BuildContext context) async { final clients=await supabase.from('profiles').select('id,full_name').eq('role','client').order('full_name'); if(!context.mounted)return; String? uid=clients.isNotEmpty?clients.first['id']:null; final no=TextEditingController(),name=TextEditingController(),type=TextEditingController(),notes=TextEditingController(); String? selected=uid; await showDialog(context:context,builder:(d)=>StatefulBuilder(builder:(d,set)=>AlertDialog(backgroundColor:navy2,title:const Text('إضافة قضية',style:TextStyle(color:text)),content:SingleChildScrollView(child:Column(children:[_dialogField(no,'رقم القضية'),_dialogField(name,'اسم العميل'),_dialogField(type,'نوع القضية'),_dialogField(notes,'ملاحظات'),if(clients.isNotEmpty)DropdownButtonFormField<String>(initialValue:selected,dropdownColor:navy2,decoration:const InputDecoration(labelText:'حساب العميل',labelStyle:TextStyle(color:muted)),items:clients.map((x)=>DropdownMenuItem(value:x['id'].toString(),child:Text(x['full_name']??'عميل',style:const TextStyle(color:text)))).toList(),onChanged:(v)=>set(()=>selected=v))])),actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('إلغاء')),FilledButton(onPressed:clients.isEmpty?null:()async{await supabase.from('cases').insert({'user_id':selected,'case_number':no.text.trim(),'client_name':name.text.trim(),'case_type':type.text.trim(),'notes':notes.text.trim()});if(d.mounted)Navigator.pop(d);if(context.mounted)_snack(context,'تمت إضافة القضية');},child:const Text('حفظ'))])));}
Future<void> _showAddAppointment(BuildContext context) async { final clients=await supabase.from('profiles').select('id,full_name').eq('role','client').order('full_name'); if(!context.mounted)return; String? selected=clients.isNotEmpty?clients.first['id']:null; final title=TextEditingController(),date=TextEditingController(); await showDialog(context:context,builder:(d)=>AlertDialog(backgroundColor:navy2,title:const Text('إضافة جلسة',style:TextStyle(color:text)),content:SingleChildScrollView(child:Column(children:[_dialogField(title,'عنوان الجلسة'),_dialogField(date,'التاريخ والوقت ISO - مثال 2026-10-01T10:00:00+03:00'),if(clients.isNotEmpty)DropdownButtonFormField<String>(initialValue:selected,dropdownColor:navy2,items:clients.map((x)=>DropdownMenuItem(value:x['id'].toString(),child:Text(x['full_name']??'عميل',style:const TextStyle(color:text)))).toList(),onChanged:(v)=>selected=v,decoration:const InputDecoration(labelText:'العميل',labelStyle:TextStyle(color:muted)))])),actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('إلغاء')),FilledButton(onPressed:clients.isEmpty?null:()async{try{await supabase.from('appointments').insert({'user_id':selected,'title':title.text.trim(),'appointment_at':date.text.trim()});if(d.mounted)Navigator.pop(d);if(context.mounted)_snack(context,'تمت إضافة الجلسة');}catch(e){if(context.mounted)_snack(context,'راجع صيغة التاريخ والوقت');}},child:const Text('حفظ'))]));}
Future<void> _showNotification(BuildContext context) async {final clients=await supabase.from('profiles').select('id,full_name').eq('role','client').order('full_name');if(!context.mounted)return;String? selected=clients.isNotEmpty?clients.first['id']:null;final title=TextEditingController(),body=TextEditingController();await showDialog(context:context,builder:(d)=>AlertDialog(backgroundColor:navy2,title:const Text('إرسال إشعار',style:TextStyle(color:text)),content:SingleChildScrollView(child:Column(children:[_dialogField(title,'عنوان الإشعار'),_dialogField(body,'نص الإشعار'),if(clients.isNotEmpty)DropdownButtonFormField<String>(initialValue:selected,dropdownColor:navy2,items:clients.map((x)=>DropdownMenuItem(value:x['id'].toString(),child:Text(x['full_name']??'عميل',style:const TextStyle(color:text)))).toList(),onChanged:(v)=>selected=v)])),actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('إلغاء')),FilledButton(onPressed:clients.isEmpty?null:()async{await supabase.from('notifications').insert({'user_id':selected,'title':title.text.trim(),'body':body.text.trim()});if(d.mounted)Navigator.pop(d);if(context.mounted)_snack(context,'تم إرسال الإشعار');},child:const Text('إرسال'))]));}

Widget _action(BuildContext c,String t,IconData i,VoidCallback f)=>Padding(padding:const EdgeInsets.only(bottom:10),child:FilledButton.icon(onPressed:f,icon:Icon(i),label:Align(alignment:Alignment.centerRight,child:Text(t)),style:FilledButton.styleFrom(minimumSize:const Size(double.infinity,52),backgroundColor:Colors.white.withValues(alpha: .06),foregroundColor:text,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)))));
Widget _dialogField(TextEditingController c,String h)=>Padding(padding:const EdgeInsets.only(bottom:10),child:TextField(controller:c,style:const TextStyle(color:text),decoration:InputDecoration(labelText:h,labelStyle:const TextStyle(color:muted),enabledBorder:const UnderlineInputBorder(borderSide:BorderSide(color:Colors.white24)),focusedBorder:const UnderlineInputBorder(borderSide:BorderSide(color:blue2))));
Widget _page({required Widget child})=>SafeArea(child:Container(decoration:const BoxDecoration(gradient:LinearGradient(colors:[navy2,navy],begin:Alignment.topCenter,end:Alignment.bottomCenter)),child:child));
Widget _card({required Widget child})=>Container(margin:const EdgeInsets.only(bottom:10),decoration:BoxDecoration(color:Colors.white.withValues(alpha: .04),borderRadius:BorderRadius.circular(18)),child:child);
Widget _stat(String l,String v,IconData i)=>Container(padding:const EdgeInsets.symmetric(vertical:16),decoration:BoxDecoration(color:Colors.white.withValues(alpha: .04),borderRadius:BorderRadius.circular(18)),child:Column(children:[Icon(i,color:blue2),const SizedBox(height:6),Text(v,style:const TextStyle(color:text,fontSize:22,fontWeight:FontWeight.w900)),Text(l,style:const TextStyle(color:muted,fontSize:11))]));
class _Loading extends StatelessWidget{const _Loading();@override Widget build(BuildContext c)=>const Center(child:CircularProgressIndicator());}
class _Empty extends StatelessWidget{final String text;const _Empty({required this.text});@override Widget build(BuildContext c)=>Padding(padding:const EdgeInsets.all(28),child:Text(text,textAlign:TextAlign.center,style:const TextStyle(color:muted)));}
Widget _error(String x)=>Center(child:Text(x,style:const TextStyle(color:muted)));
void _snack(BuildContext c,String x)=>ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text(x),behavior:SnackBarBehavior.floating));
