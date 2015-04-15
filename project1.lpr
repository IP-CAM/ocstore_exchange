program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, sqldb, db, mysql55conn,laz2_xmlread, laz2_dom

  { you can add units after this };

type

  { TMyApplication }

  TMyApplication = class(TCustomApplication)
   Query: TSQLQuery;
   Transaction: TSQLTransaction;
   Connection: TMySQL55Connection;



  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure ConServ(charset,host,user,passwd,db:shortstring);
    procedure AddProduct;
    function FindId(const typeid:string):integer;
    procedure xml_parse;
    procedure AddCategory;
    end;

  { TMyApplication  end}

{ Считываемаема инфа, будет забиваться в эту запись }
type
   PProduct = ^Product;
   Product = record
    //table product
    product_id: integer;
    model: string;
    sku: shortint;
    upc: shortint;
    ean: shortint;
    jan: shortint;
    isbn: shortint;
    mpn: shortint;
    location: shortint;
    quantity: integer;
    stock_status_id: shortint;
    image: string;
    manufacturer_id: shortint;
    shipping: shortint;
    price: integer;
    points: shortint;
    tax_class_id: shortint;
    date_avaliable: shortstring;
    weight: shortint;
    weight_class_id: shortint;
    length: shortint;
    width: shortint;
    height: shortint;
    length_class_id: shortint;
    subtract: shortint;
    minimum: shortint;
    sort_order: shortint;
    status: shortint;
    date_added: shortstring;
    date_modified: shortstring;
    viewed: shortint;
    //table description
    language_id:shortint;
    name: UTF8String;
    description: shortstring;
    meta_description: shortstring;
    meta_keyword: shortstring;
    seo_title: shortstring;
    seo_h1: shortstring;
    tag: shortstring;
    //table  product_to_category
    category_id: integer;
    main_category: integer;
    //table product_to_store
    store_id: shortint;


   next: PProduct
                  end;


   PCategory = ^Category;
   Category = record
      name:string;
      category_id:integer;
      image:string;
      parent_id:shortint;
      top:shortint;
      column:shortint;
      status:shortint;
      date_added:shortstring;
      date_modified:shortstring;
      language_id:shortint;
      sort_order:shortint;
      Next: PCategory;
   end;



const {mysql}
      m_codepage='utf8';
      m_addr='91.224.23.14';
      m_user='zhbr';
      m_password='031995911';
      m_base='zhbr';
      {/mysql}




var Products: PProduct;
    Categories: PCategory;
    ProductCount,CatCount: integer;
procedure TMyApplication.DoRun;


begin

  { add your program here }



  xml_parse;
  ConServ(m_codepage,m_addr,m_user,m_password,m_base);
  //AddCategory;
  writeln (UTF8ToAnsi('jvkhsvjkvs'));
  AddProduct;



  // stop program loop
  Terminate;
end;


procedure TMyApplication.xml_parse;
          const
          {category}
          store_id=0;
          language_id=1;
          cat_image='no_image.jpg';
          cat_status=1;
          cat_top=1;
          cat_column=1;
          cat_parent_id=0;
          cat_date_added='2015-03-02 06:49:04';
          cat_date_modified='2015-03-02 06:49:04';
          cat_sort_order=1;
          {/category}

          var
          Doc:TXMLDocument;
          PassNode: TDOMNode;
          i:integer;
          cur_cat: PCategory;
          cur_prod: PProduct;
begin
  ReadXMLFile(Doc,'/home/zhbr/3.xml');
  PassNode:=Doc.DocumentElement.FindNode('GROUPS');
  //for i:= 0 to (PassNode.ChildNodes.Count-1) do writeln(Passnode.ChildNodes.Item[i].Attributes.Item[0].NodeValue);
  // Парсим категории
  New(Categories);
  cur_cat:=Categories;
  for i:=0 to (PassNode.ChildNodes.Count-1) do
   begin
   cur_cat^.category_id:=StrToInt(Passnode.ChildNodes.Item[i].Attributes.Item[2].NodeValue);
   cur_cat^.name:=Passnode.ChildNodes.Item[i].Attributes.Item[0].NodeValue;
   cur_cat^.language_id:=language_id;
   cur_cat^.image:=cat_image;
   cur_cat^.status:=cat_status;
   cur_cat^.top:=cat_top;
   cur_cat^.column:=cat_column;
   cur_cat^.parent_id:=cat_parent_id;
   cur_cat^.date_added:=cat_date_added;
   cur_cat^.date_modified:=cat_date_modified;
   cur_cat^.sort_order:=cat_sort_order;
   if i = PassNode.ChildNodes.Count-1 then break;
   New(cur_cat^.Next);
   cur_cat:=cur_cat^.Next;

   end;
  cur_cat^.Next:=nil;
  dispose(cur_cat);
  writeln ('Категории найдены ',PassNode.ChildNodes.Count-1,' ', PassNode.ChildNodes.Count);
  readln;

  //Парсим товары
  PassNode:=Doc.DocumentElement.FindNode('GOODS');
  New(Products);
  cur_prod:= Products;
  i:=0;
  for i:= 0 to (PassNode.ChildNodes.Count - 1) do
   begin
   //writeln (StrToInt(PassNode.ChildNodes.Item[i].Attributes.Item[0].NodeValue));
   cur_prod^.product_id:=StrToInt(PassNode.ChildNodes.Item[i].Attributes.Item[0].NodeValue);
   cur_prod^.model:='-';
   cur_prod^.sku:=0;
   cur_prod^.upc:=0;
   cur_prod^.ean:=0;
   cur_prod^.jan:=0;
   cur_prod^.isbn:=0;
   cur_prod^.mpn:=0;
   cur_prod^.location:=0;
   cur_prod^.quantity:=StrToInt(PassNode.ChildNodes.Item[i].Attributes.Item[4].NodeValue);
   cur_prod^.stock_status_id:=6;
   cur_prod^.image:='no_image.jpg';
   cur_prod^.manufacturer_id:=0;
   cur_prod^.shipping:=1;
   cur_prod^.price:=Round(StrToFloat(PassNode.ChildNodes.Item[i].Attributes.Item[5].NodeValue));
   cur_prod^.points:=0;
   cur_prod^.tax_class_id:=9;
   cur_prod^.date_avaliable:='2015.04.01';
   cur_prod^.weight_class_id:=1;
   cur_prod^.length:=0;
   cur_prod^.width:=0;
   cur_prod^.height:=0;
   cur_prod^.length_class_id:=1;
   cur_prod^.subtract:=0;
   cur_prod^.minimum:=1;
   cur_prod^.sort_order:=1;
   cur_prod^.status:=1;
   cur_prod^.date_added:='2015-04-01 00:00:00';
   cur_prod^.date_modified:='0000-00-00 00:00:00';
   cur_prod^.viewed:=0;
   cur_prod^.language_id:=1;
   cur_prod^.name:=PassNode.ChildNodes.Item[i].Attributes.Item[1].NodeValue;
   cur_prod^.description:='';
   cur_prod^.meta_description:='';
   cur_prod^.meta_keyword:='';
   cur_prod^.seo_title:='';
   cur_prod^.seo_h1:='';
   cur_prod^.tag:='';
   cur_prod^.category_id:=StrToInt(PassNode.ChildNodes.Item[i].Attributes.Item[3].NodeValue);
   cur_prod^.main_category:=1;
   cur_prod^.store_id:=0;
   //writeln (PassNode.ChildNodes.Item[i].Attributes.Item[0].NodeValue,' ',cur_prod^.product_id, ' ', IntToStr(cur_prod^.product_id));
   writeln (cur_prod^.category_id);
   New(cur_prod^.next);
   cur_prod:= cur_prod^.next;


   end;
   cur_prod^.next:=nil;
   writeln ('Товары найдены');
   readln;

   PassNode.Free;
   Doc.Free;

end;

function TMyApplication.FindId(const typeid:string):integer;
var maxid:integer;
begin
  try
  Query.SQL.Clear;
  Query.SQL.Add('SELECT * FROM '+typeid);
  Query.Open;
  Query.First;
  maxid:= 0;

  while not Query.EOF do begin
        if maxid < Query.FieldByName(typeid+'_id').AsInteger then maxid:= Query.FieldByName(typeid+'_id').AsInteger;
        Query.Next;
        end;
  Query.Close;
  Query.SQL.Clear;
  except on E: EDataBaseError do writeln (e.Message);
  end;
  FindId:=maxid+1;
end;

procedure   TMyApplication.AddProduct;

var
  i: longint;
  temp1 : PProduct;
begin
  temp1:=Products;
  while temp1^.next <> nil do
  begin
  writeln ('Добавление товара: ',temp1^.name);
  try
  Query.SQL.Clear;
  Query.SQL.Add('INSERT INTO '+m_base+'.`oc_product_description` (`product_id`, `language_id`, `name`, `description`, `meta_description`, `meta_keyword`, `seo_title`, `seo_h1`, `tag`) VALUES ('''+IntToStr(temp1^.product_id)+''', '''+IntToStr(temp1^.language_id)+''', '''+temp1^.name+''', '''+temp1^.description+''', '''+temp1^.meta_description+''', '''+temp1^.meta_keyword+''', '''+temp1^.seo_title+''', '''+temp1^.seo_h1+''', '''+temp1^.tag+''');');
  Query.ExecSQL;
  Query.SQL.Clear;
  Query.SQL.Add('INSERT INTO '+m_base+'.`oc_product` (`product_id`, `model`,`sku`, `upc`, `ean`, `jan`, `isbn`, `mpn`, `location`, `quantity`, `stock_status_id`, `image`, `manufacturer_id`, `shipping`, `price`, `points`, `tax_class_id`, `date_available`, `weight`, `weight_class_id`, `length`, `width`, `height`, `length_class_id`, `subtract`, `minimum`, `sort_order`, `status`, `date_added`, `date_modified`, `viewed`) VALUES ('''+IntToStr(temp1^.product_id)+''','''+temp1^.model+''', '''+IntToStr(temp1^.sku)+''', '''+IntToStr(temp1^.upc)+''', '''+IntToStr(temp1^.ean)+''', '''+IntToStr(temp1^.jan)+''', '''+IntToStr(temp1^.isbn)+''', '''+IntToStr(temp1^.mpn)+''', '''+IntToStr(temp1^.location)+''', '''+IntToStr(temp1^.quantity)+''', '''+IntToStr(temp1^.stock_status_id)+''','''+temp1^.image+''','''+IntToStr(temp1^.manufacturer_id)+''', '''+IntToStr(temp1^.shipping)+''', '''+IntToStr(temp1^.price)+''', '''+IntToStr(temp1^.points)+''', '''+IntToStr(temp1^.tax_class_id)+''', '''+temp1^.date_avaliable+''','''+IntToStr(temp1^.weight)+''', '''+IntToStr(temp1^.weight_class_id)+''', '''+IntToStr(temp1^.length)+''', '''+IntToStr(temp1^.width)+''', '''+IntToStr(temp1^.height)+''', '''+IntToStr(temp1^.length_class_id)+''', '''+IntToStr(temp1^.subtract)+''', '''+IntToStr(temp1^.minimum)+''', '''+IntToStr(temp1^.sort_order)+''', '''+IntToStr(temp1^.status)+''', '''+temp1^.date_added+''', '''+temp1^.date_modified+''', '''+IntToStr(temp1^.viewed)+''');');
  Query.ExecSQL;
  Query.SQL.Clear;
  Query.SQL.Add('INSERT INTO '+m_base+'.`oc_product_to_category` (`product_id`, `category_id`, `main_category`) VALUES ('''+IntToStr(temp1^.product_id)+''', '''+IntToStr(temp1^.category_id)+''', '''+IntToStr(temp1^.main_category)+''');');
  Query.ExecSQL;
  Query.SQL.Clear;
  Query.SQL.Add('INSERT INTO '+m_base+'.oc_product_to_store (product_id, store_id) VALUES ('''+IntToStr(temp1^.product_id)+''', '''+IntToStr(temp1^.store_id)+''');');
  Query.ExecSQL;
  except
   on E: EDatabaseError do writeln ('Error:',E.Message);

  end;
  temp1:=temp1^.next;
  end;
  Readln;
end;




procedure TMyApplication.AddCategory;
var    temp: PCategory;
    y,i: integer;
begin
  temp:=Categories;
  y:=1;
  while temp^.next <> nil do begin
  writeln('Добавление категории: ',temp^.name);

  //try

  //writeln ('INSERT INTO '+m_base+'.oc_category (category_id, image, parent_id, top, `column`, sort_order, status, date_added, date_modified) VALUES( '''+IntToStr(temp^.category_id)+''', '''+temp^.image+''', '''+IntToStr(temp^.parent_id)+''', '''+IntToStr(temp^.top)+''', '''+IntToStr(temp^.column)+''', '''+IntToStr(temp^.sort_order)+''', '''+IntToStr(temp^.status)+''', '''+temp^.date_added+''', '''+temp^.date_modified+''');');
  Query.SQL.Clear;
  Query.SQL.Add('INSERT INTO '+m_base+'.oc_category (category_id, image, parent_id, top, `column`, sort_order, status, date_added, date_modified) VALUES( '''+IntToStr(temp^.category_id)+''', '''+temp^.image+''', '''+IntToStr(temp^.parent_id)+''', '''+IntToStr(temp^.top)+''', '''+IntToStr(temp^.column)+''', '''+IntToStr(temp^.sort_order)+''', '''+IntToStr(temp^.status)+''', '''+temp^.date_added+''', '''+temp^.date_modified+''');');
  Query.ExecSQL;

  Query.SQL.Clear;
  Query.SQL.Add('INSERT INTO '+m_base+'.oc_category_description (category_id, language_id, name, description, meta_description, meta_keyword, seo_title, seo_h1) VALUES('''+IntToStr(temp^.category_id)+''', '''+IntToStr(temp^.language_id)+''', '''+temp^.name+''', '''', '''', '''', '''', '''');');
  Query.ExecSQL;

  Query.SQL.Clear;
  Query.SQL.Add('INSERT INTO '+m_base+'.oc_category_path (category_id, path_id, level) VALUES( '''+IntToStr(temp^.category_id)+''', '''+IntToStr(temp^.category_id)+''', 1);');
  Query.ExecSQL;

  Query.SQL.Clear;
  Query.SQL.Add('INSERT INTO '+m_base+'.oc_category_to_store (category_id, store_id) VALUES('''+IntToStr(temp^.category_id)+''', 0);');
  Query.ExecSQL;
  Query.SQL.Clear;

  temp:=temp^.next;
  writeln('1111: ',temp^.name);

  writeln(y);
  y:=y+1;

  //except on E: EdatabaseError do begin
  //                               writeln (E.Message);
  //                               halt;
  //                              end;
  end;
end;
//end;

procedure TMyApplication.ConServ(charset,host,user,passwd,db:shortstring);
var a:string;
begin
   Writeln('Инициализация...');
   Try
   Connection := TMySQL55Connection.Create(nil);
   Transaction:=TSQLTransaction.Create(nil);
   Query:= TSQLQuery.Create(nil);
   Writeln ('Выполнена!');
   except on E: EDataBaseError do Writeln ('Ошибка: ', E.Message);
   end;
   Writeln ('Подключение к серверу ',host,'...');
   Connection.CharSet:=charset;
   Connection.HostName:=host;
   Connection.DatabaseName:=db;
   Connection.UserName:=user;
   Connection.Password:=passwd;
   try
   Transaction.DataBase:=Connection;
   Query.DataBase:=Connection;
   Connection.Connected:=True;
   Writeln ('Подключение прошло успешно!');
   except
     on E: EDatabaseError do begin
       writeln ('Ошибка: ',E.message);
       writeln ('Проверьте правильность учетных данных!');
       halt;
    end;
   end;
end;





constructor TMyApplication.Create(TheOwner: TComponent);


begin
  inherited Create(TheOwner);
  StopOnException:=True;

end;

destructor TMyApplication.Destroy;
begin
  inherited Destroy;
end;

var
  Application: TMyApplication;

begin
  Application:=TMyApplication.Create(nil);
  Application.Title:='Exchange';
  Application.Run;
  Application.Free;
end.

