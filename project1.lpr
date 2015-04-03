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
    product_id: shortint;
    model: shortstring;
    sku: shortint;
    upc: shortint;
    ean: shortint;
    jan: shortint;
    isbn: shortint;
    mpn: shortint;
    location: shortint;
    quantity: shortint;
    stock_status_id: shortint;
    image: string;
    manufacturer_id: shortint;
    shipping: shortint;
    price: shortint;
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
    name: string;
    description: shortstring;
    meta_description: shortstring;
    meta_keyword: shortstring;
    seo_title: shortstring;
    seo_h1: shortstring;
    tag: shortstring;
    //table  product_to_category
    category_id: shortint;
    main_category: shortint;
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
  //ConServ(m_codepage,m_addr,m_user,m_password,m_base);
  //AddCategory;


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
  ReadXMLFile(Doc,'/home/zhbr/oil.xml');
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
   New(cur_cat^.Next);
   cur_cat:=cur_cat^.Next;
   end;
  cur_cat^.Next:=nil;
  dispose(cur_cat);
  readln;

  //Парсим товары
  PassNode:=Doc.DocumentElement.FindNode('GOODS');
  New(Products);
  cur_prod:= Products;
  i:=0;
  for i:= 0 to (PassNode.ChildNodes.Count - 1) do
   begin
   writeln (StrToInt(PassNode.ChildNodes.Item[i].Attributes.Item[0].NodeValue));
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
   cur_prod^.name:=PassNode.ChildNodes.Item[i].Attributes.Item[1].NodeName;
   cur_prod^.description:='';
   cur_prod^.meta_description:='';
   cur_prod^.meta_keyword:='';
   cur_prod^.seo_title:='';
   cur_prod^.seo_h1:='';
   cur_prod^.tag:='';
   cur_prod^.category_id:=StrToInt(PassNode.ChildNodes.Item[i].Attributes.Item[3].NodeValue);
   cur_prod^.main_category:=1;
   cur_prod^.store_id:=0;
   New(cur_prod^.next);
   cur_prod:= cur_prod^.next;
   end;
   cur_prod^.next:=nil;
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
  temp : PProduct;
begin
  temp:=Products;
  while temp^.next <> nil do
  begin
  try
  Query.SQL.Clear;
  Query.SQL.Add('INSERT INTO `ocstore`.`product_description` (`product_id`, `language_id`, `name`, `description`, `meta_description`, `meta_keyword`, `seo_title`, `seo_h1`, `tag`) VALUES ('''+IntToStr(temp^.price)+''', '''+IntToStr(temp^.language_id)+''', '''+temp^.name+''', '''+temp^.description+''', '''+temp^.meta_description+''', '''+temp^.meta_keyword+''', '''+temp^.seo_title+''', '''+temp^.seo_h1+''', '''+temp^.tag+''');');
  Query.ExecSQL;
  Query.SQL.Clear;
  Query.SQL.Add('INSERT INTO `ocstore`.`product` (`product_id`, `model`,`sku`, `upc`, `ean`, `jan`, `isbn`, `mpn`, `location`, `quantity`, `stock_status_id`, `image`, `manufacturer_id`, `shipping`, `price`, `points`, `tax_class_id`, `date_available`, `weight`, `weight_class_id`, `length`, `width`, `height`, `length_class_id`, `subtract`, `minimum`, `sort_order`, `status`, `date_added`, `date_modified`, `viewed`) VALUES ('''+IntToStr(temp^.product_id)+''','''+temp^.model+''', '''+IntToStr(temp^.sku)+''', '''+IntToStr(temp^.upc)+''', '''', '''', '''', '''', '''', ''1'', ''5'','''+Products.image+''',''0'', ''1'', '''+IntToStr(Products.price)+''', ''0'', ''0'', ''2015-02-01'',''0.00000000'', ''1'', ''0.00000000'', ''0.00000000'', ''0.00000000'', ''2'', ''1'', ''1'', ''1'', ''1'', ''0000-00-00 00:00:00'', ''0000-00-00 00:00:00'', ''0'');');
  Query.ExecSQL;
  Query.SQL.Clear;
  Query.SQL.Add('INSERT INTO `ocstore`.`product_to_category` (`product_id`, `category_id`, `main_category`) VALUES ('''+IntToStr(Products.id)+''', '''+IntToStr(Categories.id)+''', ''1'');');
  Query.ExecSQL;
  Query.SQL.Clear;
  Query.SQL.Add('INSERT INTO ocstore.product_to_store (product_id, store_id) VALUES ('''+IntToStr(Products.id)+''', ''0'');');
  Query.ExecSQL;
  except
   on E: EDatabaseError do writeln ('Error:',E.Message);

  end;
  temp:=temp^.next;
  end;
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

  try
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
  writeln(y);
  y:=y+1;
  except on E: EdatabaseError do begin
                                 writeln (E.Message);
                                 halt;
                                 end;
  end;
end;
end;

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

