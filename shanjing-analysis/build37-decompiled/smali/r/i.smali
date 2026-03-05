.class Lr/i;
.super Ljava/lang/Object;
.source "SourceFile"


# static fields
.field private static n:Ljava/lang/Boolean;


# instance fields
.field final a:Z

.field final b:Ljava/lang/String;

.field final c:I

.field final d:I

.field final e:Landroid/content/Context;

.field final f:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List<",
            "Lt/g;",
            ">;"
        }
    .end annotation
.end field

.field final g:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/Integer;",
            "Lr/t;",
            ">;"
        }
    .end annotation
.end field

.field public h:Lr/o;

.field i:Landroid/database/sqlite/SQLiteDatabase;

.field private j:I

.field private k:I

.field private l:Ljava/lang/Integer;

.field private m:I


# direct methods
.method constructor <init>(Landroid/content/Context;Ljava/lang/String;IZI)V
    .locals 1

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iput-object v0, p0, Lr/i;->f:Ljava/util/List;

    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    iput-object v0, p0, Lr/i;->g:Ljava/util/Map;

    const/4 v0, 0x0

    iput v0, p0, Lr/i;->j:I

    iput v0, p0, Lr/i;->k:I

    iput v0, p0, Lr/i;->m:I

    iput-object p1, p0, Lr/i;->e:Landroid/content/Context;

    iput-object p2, p0, Lr/i;->b:Ljava/lang/String;

    iput-boolean p4, p0, Lr/i;->a:Z

    iput p3, p0, Lr/i;->c:I

    iput p5, p0, Lr/i;->d:I

    return-void
.end method

.method private static synthetic G(Lr/d0;Landroid/database/sqlite/SQLiteDatabase;Landroid/database/sqlite/SQLiteCursorDriver;Ljava/lang/String;Landroid/database/sqlite/SQLiteQuery;)Landroid/database/Cursor;
    .locals 0

    invoke-virtual {p0, p4}, Lr/d0;->a(Landroid/database/sqlite/SQLiteProgram;)V

    new-instance p0, Landroid/database/sqlite/SQLiteCursor;

    invoke-direct {p0, p2, p3, p4}, Landroid/database/sqlite/SQLiteCursor;-><init>(Landroid/database/sqlite/SQLiteCursorDriver;Ljava/lang/String;Landroid/database/sqlite/SQLiteQuery;)V

    return-object p0
.end method

.method private synthetic H(Lt/e;)V
    .locals 4

    invoke-interface {p1}, Lt/e;->f()Ljava/lang/Boolean;

    move-result-object v0

    sget-object v1, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    invoke-virtual {v1, v0}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v1

    const/4 v2, 0x1

    if-eqz v1, :cond_0

    invoke-interface {p1}, Lt/e;->h()Z

    move-result v1

    if-eqz v1, :cond_0

    const/4 v1, 0x1

    goto :goto_0

    :cond_0
    const/4 v1, 0x0

    :goto_0
    if-eqz v1, :cond_1

    iget v3, p0, Lr/i;->k:I

    add-int/2addr v3, v2

    iput v3, p0, Lr/i;->k:I

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    iput-object v2, p0, Lr/i;->l:Ljava/lang/Integer;

    :cond_1
    invoke-direct {p0, p1}, Lr/i;->w(Lt/e;)Z

    move-result v2

    const/4 v3, 0x0

    if-nez v2, :cond_2

    if-eqz v1, :cond_5

    iput-object v3, p0, Lr/i;->l:Ljava/lang/Integer;

    goto :goto_1

    :cond_2
    if-eqz v1, :cond_3

    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    iget-object v1, p0, Lr/i;->l:Ljava/lang/Integer;

    const-string v2, "transactionId"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    invoke-interface {p1, v0}, Lt/f;->a(Ljava/lang/Object;)V

    goto :goto_1

    :cond_3
    sget-object v1, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    invoke-virtual {v1, v0}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_4

    iput-object v3, p0, Lr/i;->l:Ljava/lang/Integer;

    :cond_4
    invoke-interface {p1, v3}, Lt/f;->a(Ljava/lang/Object;)V

    :cond_5
    :goto_1
    return-void
.end method

.method private synthetic I(Lt/e;)V
    .locals 0

    invoke-direct {p0, p1}, Lr/i;->q(Lt/e;)Z

    return-void
.end method

.method private synthetic J(Lt/e;)V
    .locals 0

    invoke-direct {p0, p1}, Lr/i;->r(Lt/e;)Z

    return-void
.end method

.method private synthetic K(Lt/e;)V
    .locals 0

    invoke-direct {p0, p1}, Lr/i;->s(Lt/e;)Z

    return-void
.end method

.method private synthetic L(Lt/e;)V
    .locals 0

    invoke-direct {p0, p1}, Lr/i;->t(Lt/e;)Z

    return-void
.end method

.method private Q()V
    .locals 2

    :goto_0
    iget-object v0, p0, Lr/i;->f:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->isEmpty()Z

    move-result v0

    if-nez v0, :cond_1

    iget-object v0, p0, Lr/i;->l:Ljava/lang/Integer;

    if-eqz v0, :cond_0

    goto :goto_1

    :cond_0
    iget-object v0, p0, Lr/i;->f:Ljava/util/List;

    const/4 v1, 0x0

    invoke-interface {v0, v1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lt/g;

    invoke-virtual {v0}, Lt/g;->a()V

    iget-object v0, p0, Lr/i;->f:Ljava/util/List;

    invoke-interface {v0, v1}, Ljava/util/List;->remove(I)Ljava/lang/Object;

    goto :goto_0

    :cond_1
    :goto_1
    return-void
.end method

.method private S(Lt/e;Ljava/lang/Runnable;)V
    .locals 2

    invoke-interface {p1}, Lt/e;->g()Ljava/lang/Integer;

    move-result-object v0

    iget-object v1, p0, Lr/i;->l:Ljava/lang/Integer;

    if-nez v1, :cond_0

    invoke-interface {p2}, Ljava/lang/Runnable;->run()V

    goto :goto_0

    :cond_0
    if-eqz v0, :cond_2

    invoke-virtual {v0, v1}, Ljava/lang/Integer;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_1

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    const/4 v1, -0x1

    if-ne v0, v1, :cond_2

    :cond_1
    invoke-interface {p2}, Ljava/lang/Runnable;->run()V

    iget-object p1, p0, Lr/i;->l:Ljava/lang/Integer;

    if-nez p1, :cond_3

    iget-object p1, p0, Lr/i;->f:Ljava/util/List;

    invoke-interface {p1}, Ljava/util/List;->isEmpty()Z

    move-result p1

    if-nez p1, :cond_3

    iget-object p1, p0, Lr/i;->h:Lr/o;

    new-instance p2, Lr/h;

    invoke-direct {p2, p0}, Lr/h;-><init>(Lr/i;)V

    invoke-interface {p1, p0, p2}, Lr/o;->c(Lr/i;Ljava/lang/Runnable;)V

    goto :goto_0

    :cond_2
    new-instance v0, Lt/g;

    invoke-direct {v0, p1, p2}, Lt/g;-><init>(Lt/e;Ljava/lang/Runnable;)V

    iget-object p1, p0, Lr/i;->f:Ljava/util/List;

    invoke-interface {p1, v0}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    :cond_3
    :goto_0
    return-void
.end method

.method public static synthetic a(Lr/i;Lt/e;)V
    .locals 0

    invoke-direct {p0, p1}, Lr/i;->I(Lt/e;)V

    return-void
.end method

.method public static synthetic b(Lr/i;Lt/e;)V
    .locals 0

    invoke-direct {p0, p1}, Lr/i;->K(Lt/e;)V

    return-void
.end method

.method public static synthetic c(Lr/i;Lt/e;)V
    .locals 0

    invoke-direct {p0, p1}, Lr/i;->J(Lt/e;)V

    return-void
.end method

.method public static synthetic d(Lr/i;)V
    .locals 0

    invoke-direct {p0}, Lr/i;->Q()V

    return-void
.end method

.method public static synthetic e(Lr/d0;Landroid/database/sqlite/SQLiteDatabase;Landroid/database/sqlite/SQLiteCursorDriver;Ljava/lang/String;Landroid/database/sqlite/SQLiteQuery;)Landroid/database/Cursor;
    .locals 0

    invoke-static {p0, p1, p2, p3, p4}, Lr/i;->G(Lr/d0;Landroid/database/sqlite/SQLiteDatabase;Landroid/database/sqlite/SQLiteCursorDriver;Ljava/lang/String;Landroid/database/sqlite/SQLiteQuery;)Landroid/database/Cursor;

    move-result-object p0

    return-object p0
.end method

.method public static synthetic f(Lr/i;Lt/e;)V
    .locals 0

    invoke-direct {p0, p1}, Lr/i;->L(Lt/e;)V

    return-void
.end method

.method public static synthetic g(Lr/i;Lt/e;)V
    .locals 0

    invoke-direct {p0, p1}, Lr/i;->H(Lt/e;)V

    return-void
.end method

.method protected static i(Landroid/content/Context;Ljava/lang/String;Z)Z
    .locals 3

    :try_start_0
    invoke-virtual {p0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v0

    sget v1, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v2, 0x21

    if-lt v1, v2, :cond_0

    invoke-virtual {p0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object p0

    const-wide/16 v1, 0x80

    invoke-static {v1, v2}, Landroid/content/pm/PackageManager$ApplicationInfoFlags;->of(J)Landroid/content/pm/PackageManager$ApplicationInfoFlags;

    move-result-object v1

    invoke-virtual {p0, v0, v1}, Landroid/content/pm/PackageManager;->getApplicationInfo(Ljava/lang/String;Landroid/content/pm/PackageManager$ApplicationInfoFlags;)Landroid/content/pm/ApplicationInfo;

    move-result-object p0

    goto :goto_0

    :cond_0
    const/16 v1, 0x80

    invoke-static {p0, v0, v1}, Lr/i;->y(Landroid/content/Context;Ljava/lang/String;I)Landroid/content/pm/ApplicationInfo;

    move-result-object p0

    :goto_0
    iget-object p0, p0, Landroid/content/pm/ApplicationInfo;->metaData:Landroid/os/Bundle;

    invoke-virtual {p0, p1, p2}, Landroid/os/Bundle;->getBoolean(Ljava/lang/String;Z)Z

    move-result p0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    if-eqz p0, :cond_1

    const/4 p0, 0x1

    return p0

    :catch_0
    move-exception p0

    invoke-virtual {p0}, Ljava/lang/Throwable;->printStackTrace()V

    :cond_1
    const/4 p0, 0x0

    return p0
.end method

.method protected static j(Landroid/content/Context;)Z
    .locals 2

    const-string v0, "com.tekartik.sqflite.wal_enabled"

    const/4 v1, 0x0

    invoke-static {p0, v0, v1}, Lr/i;->i(Landroid/content/Context;Ljava/lang/String;Z)Z

    move-result p0

    return p0
.end method

.method private l(I)V
    .locals 1

    iget-object v0, p0, Lr/i;->g:Ljava/util/Map;

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    invoke-interface {v0, p1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Lr/t;

    if-eqz p1, :cond_0

    invoke-direct {p0, p1}, Lr/i;->m(Lr/t;)V

    :cond_0
    return-void
.end method

.method private m(Lr/t;)V
    .locals 4

    :try_start_0
    iget v0, p1, Lr/t;->a:I

    iget v1, p0, Lr/i;->d:I

    invoke-static {v1}, Lr/r;->c(I)Z

    move-result v1

    if-eqz v1, :cond_0

    const-string v1, "Sqflite"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p0}, Lr/i;->A()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v3, "closing cursor "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    :cond_0
    iget-object v1, p0, Lr/i;->g:Ljava/util/Map;

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    invoke-interface {v1, v0}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    iget-object p1, p1, Lr/t;->c:Landroid/database/Cursor;

    invoke-interface {p1}, Landroid/database/Cursor;->close()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    :catch_0
    return-void
.end method

.method private n(Landroid/database/Cursor;Ljava/lang/Integer;)Ljava/util/Map;
    .locals 6
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Landroid/database/Cursor;",
            "Ljava/lang/Integer;",
            ")",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation

    const/4 v0, 0x0

    const/4 v1, 0x0

    move-object v1, v0

    const/4 v2, 0x0

    :cond_0
    invoke-interface {p1}, Landroid/database/Cursor;->moveToNext()Z

    move-result v3

    if-eqz v3, :cond_2

    if-nez v0, :cond_1

    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    new-instance v1, Ljava/util/HashMap;

    invoke-direct {v1}, Ljava/util/HashMap;-><init>()V

    invoke-interface {p1}, Landroid/database/Cursor;->getColumnCount()I

    move-result v2

    invoke-interface {p1}, Landroid/database/Cursor;->getColumnNames()[Ljava/lang/String;

    move-result-object v3

    invoke-static {v3}, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v3

    const-string v4, "columns"

    invoke-interface {v1, v4, v3}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v3, "rows"

    invoke-interface {v1, v3, v0}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    move-object v5, v1

    move-object v1, v0

    move-object v0, v5

    :cond_1
    invoke-static {p1, v2}, Lr/e0;->a(Landroid/database/Cursor;I)Ljava/util/List;

    move-result-object v3

    invoke-interface {v1, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    if-eqz p2, :cond_0

    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v3

    invoke-virtual {p2}, Ljava/lang/Integer;->intValue()I

    move-result v4

    if-lt v3, v4, :cond_0

    :cond_2
    if-nez v0, :cond_3

    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    :cond_3
    return-object v0
.end method

.method static o(Ljava/lang/String;)V
    .locals 1

    new-instance v0, Ljava/io/File;

    invoke-direct {v0, p0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-static {v0}, Landroid/database/sqlite/SQLiteDatabase;->deleteDatabase(Ljava/io/File;)Z

    return-void
.end method

.method private p(Lt/e;)Z
    .locals 1

    invoke-direct {p0, p1}, Lr/i;->w(Lt/e;)Z

    move-result v0

    if-nez v0, :cond_0

    const/4 p1, 0x0

    return p1

    :cond_0
    const/4 v0, 0x0

    invoke-interface {p1, v0}, Lt/f;->a(Ljava/lang/Object;)V

    const/4 p1, 0x1

    return p1
.end method

.method private q(Lt/e;)Z
    .locals 9

    invoke-direct {p0, p1}, Lr/i;->w(Lt/e;)Z

    move-result v0

    const/4 v1, 0x0

    if-nez v0, :cond_0

    return v1

    :cond_0
    invoke-interface {p1}, Lt/e;->e()Z

    move-result v0

    const/4 v2, 0x0

    const/4 v3, 0x1

    if-eqz v0, :cond_1

    invoke-interface {p1, v2}, Lt/f;->a(Ljava/lang/Object;)V

    return v3

    :cond_1
    const-string v0, "SELECT changes(), last_insert_rowid()"

    :try_start_0
    invoke-virtual {p0}, Lr/i;->C()Landroid/database/sqlite/SQLiteDatabase;

    move-result-object v4

    invoke-virtual {v4, v0, v2}, Landroid/database/sqlite/SQLiteDatabase;->rawQuery(Ljava/lang/String;[Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    const-string v4, "Sqflite"

    if-eqz v0, :cond_5

    :try_start_1
    invoke-interface {v0}, Landroid/database/Cursor;->getCount()I

    move-result v5

    if-lez v5, :cond_5

    invoke-interface {v0}, Landroid/database/Cursor;->moveToFirst()Z

    move-result v5

    if-eqz v5, :cond_5

    invoke-interface {v0, v1}, Landroid/database/Cursor;->getInt(I)I

    move-result v5

    if-nez v5, :cond_3

    iget v5, p0, Lr/i;->d:I

    invoke-static {v5}, Lr/r;->b(I)Z

    move-result v5

    if-eqz v5, :cond_2

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p0}, Lr/i;->A()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v6, "no changes (id was "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-interface {v0, v3}, Landroid/database/Cursor;->getLong(I)J

    move-result-wide v6

    invoke-virtual {v5, v6, v7}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    const-string v6, ")"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v4, v5}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    :cond_2
    invoke-interface {p1, v2}, Lt/f;->a(Ljava/lang/Object;)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    invoke-interface {v0}, Landroid/database/Cursor;->close()V

    return v3

    :cond_3
    :try_start_2
    invoke-interface {v0, v3}, Landroid/database/Cursor;->getLong(I)J

    move-result-wide v5

    iget v2, p0, Lr/i;->d:I

    invoke-static {v2}, Lr/r;->b(I)Z

    move-result v2

    if-eqz v2, :cond_4

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p0}, Lr/i;->A()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v2, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v7, "inserted "

    invoke-virtual {v2, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, v5, v6}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v4, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    :cond_4
    invoke-static {v5, v6}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v2

    invoke-interface {p1, v2}, Lt/f;->a(Ljava/lang/Object;)V
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_0
    .catchall {:try_start_2 .. :try_end_2} :catchall_1

    invoke-interface {v0}, Landroid/database/Cursor;->close()V

    return v3

    :catch_0
    move-exception v2

    goto :goto_0

    :cond_5
    :try_start_3
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p0}, Lr/i;->A()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v6, "fail to read changes for Insert"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v4, v5}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    invoke-interface {p1, v2}, Lt/f;->a(Ljava/lang/Object;)V
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_0
    .catchall {:try_start_3 .. :try_end_3} :catchall_1

    if-eqz v0, :cond_6

    invoke-interface {v0}, Landroid/database/Cursor;->close()V

    :cond_6
    return v3

    :catchall_0
    move-exception p1

    goto :goto_1

    :catch_1
    move-exception v0

    move-object v8, v2

    move-object v2, v0

    move-object v0, v8

    :goto_0
    :try_start_4
    invoke-virtual {p0, v2, p1}, Lr/i;->D(Ljava/lang/Exception;Lt/e;)V
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_1

    if-eqz v0, :cond_7

    invoke-interface {v0}, Landroid/database/Cursor;->close()V

    :cond_7
    return v1

    :catchall_1
    move-exception p1

    move-object v2, v0

    :goto_1
    if-eqz v2, :cond_8

    invoke-interface {v2}, Landroid/database/Cursor;->close()V

    :cond_8
    throw p1
.end method

.method private r(Lt/e;)Z
    .locals 9

    const-string v0, "cursorPageSize"

    invoke-interface {p1, v0}, Lt/e;->c(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-interface {p1}, Lt/e;->d()Lr/d0;

    move-result-object v1

    iget v2, p0, Lr/i;->d:I

    invoke-static {v2}, Lr/r;->b(I)Z

    move-result v2

    if-eqz v2, :cond_0

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p0}, Lr/i;->A()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    const-string v3, "Sqflite"

    invoke-static {v3, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    :cond_0
    const/4 v2, 0x0

    const/4 v3, 0x0

    :try_start_0
    invoke-virtual {p0}, Lr/i;->z()Landroid/database/sqlite/SQLiteDatabase;

    move-result-object v4

    new-instance v5, Lr/f;

    invoke-direct {v5, v1}, Lr/f;-><init>(Lr/d0;)V

    invoke-virtual {v1}, Lr/d0;->c()Ljava/lang/String;

    move-result-object v1

    sget-object v6, Lr/a;->a:[Ljava/lang/String;

    invoke-virtual {v4, v5, v1, v6, v2}, Landroid/database/sqlite/SQLiteDatabase;->rawQueryWithFactory(Landroid/database/sqlite/SQLiteDatabase$CursorFactory;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object v1
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_2
    .catchall {:try_start_0 .. :try_end_0} :catchall_1

    :try_start_1
    invoke-direct {p0, v1, v0}, Lr/i;->n(Landroid/database/Cursor;Ljava/lang/Integer;)Ljava/util/Map;

    move-result-object v4

    const/4 v5, 0x1

    if-eqz v0, :cond_1

    invoke-interface {v1}, Landroid/database/Cursor;->isLast()Z

    move-result v6

    if-nez v6, :cond_1

    invoke-interface {v1}, Landroid/database/Cursor;->isAfterLast()Z

    move-result v6

    if-nez v6, :cond_1

    const/4 v6, 0x1

    goto :goto_0

    :cond_1
    const/4 v6, 0x0

    :goto_0
    if-eqz v6, :cond_2

    iget v6, p0, Lr/i;->m:I

    add-int/2addr v6, v5

    iput v6, p0, Lr/i;->m:I

    const-string v7, "cursorId"

    invoke-static {v6}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v8

    invoke-interface {v4, v7, v8}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    new-instance v7, Lr/t;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    invoke-direct {v7, v6, v0, v1}, Lr/t;-><init>(IILandroid/database/Cursor;)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_2

    :try_start_2
    iget-object v0, p0, Lr/i;->g:Ljava/util/Map;

    invoke-static {v6}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v2, v7}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_0
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    move-object v2, v7

    goto :goto_1

    :catchall_0
    move-exception p1

    move-object v2, v7

    goto :goto_3

    :catch_0
    move-exception v0

    move-object v2, v7

    goto :goto_2

    :cond_2
    :goto_1
    :try_start_3
    invoke-interface {p1, v4}, Lt/f;->a(Ljava/lang/Object;)V
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_1
    .catchall {:try_start_3 .. :try_end_3} :catchall_2

    if-nez v2, :cond_3

    if-eqz v1, :cond_3

    invoke-interface {v1}, Landroid/database/Cursor;->close()V

    :cond_3
    return v5

    :catch_1
    move-exception v0

    goto :goto_2

    :catchall_1
    move-exception p1

    move-object v1, v2

    goto :goto_3

    :catch_2
    move-exception v0

    move-object v1, v2

    :goto_2
    :try_start_4
    invoke-virtual {p0, v0, p1}, Lr/i;->D(Ljava/lang/Exception;Lt/e;)V

    if-eqz v2, :cond_4

    invoke-direct {p0, v2}, Lr/i;->m(Lr/t;)V
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_2

    :cond_4
    if-nez v2, :cond_5

    if-eqz v1, :cond_5

    invoke-interface {v1}, Landroid/database/Cursor;->close()V

    :cond_5
    return v3

    :catchall_2
    move-exception p1

    :goto_3
    if-nez v2, :cond_6

    if-eqz v1, :cond_6

    invoke-interface {v1}, Landroid/database/Cursor;->close()V

    :cond_6
    throw p1
.end method

.method private s(Lt/e;)Z
    .locals 9

    const-string v0, "cursorId"

    invoke-interface {p1, v0}, Lt/e;->c(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Integer;

    invoke-virtual {v1}, Ljava/lang/Integer;->intValue()I

    move-result v1

    sget-object v2, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    const-string v3, "cancel"

    invoke-interface {p1, v3}, Lt/e;->c(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v2

    iget v3, p0, Lr/i;->d:I

    invoke-static {v3}, Lr/r;->c(I)Z

    move-result v3

    if-eqz v3, :cond_1

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p0}, Lr/i;->A()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v4, "cursor "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    if-eqz v2, :cond_0

    const-string v4, " cancel"

    goto :goto_0

    :cond_0
    const-string v4, " next"

    :goto_0
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    const-string v4, "Sqflite"

    invoke-static {v4, v3}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    :cond_1
    const/4 v3, 0x0

    const/4 v4, 0x1

    if-eqz v2, :cond_2

    invoke-direct {p0, v1}, Lr/i;->l(I)V

    invoke-interface {p1, v3}, Lt/f;->a(Ljava/lang/Object;)V

    return v4

    :cond_2
    iget-object v2, p0, Lr/i;->g:Ljava/util/Map;

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    invoke-interface {v2, v5}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lr/t;

    const/4 v5, 0x0

    if-eqz v2, :cond_6

    :try_start_0
    iget-object v6, v2, Lr/t;->c:Landroid/database/Cursor;

    iget v7, v2, Lr/t;->b:I

    invoke-static {v7}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v7

    invoke-direct {p0, v6, v7}, Lr/i;->n(Landroid/database/Cursor;Ljava/lang/Integer;)Ljava/util/Map;

    move-result-object v7

    invoke-interface {v6}, Landroid/database/Cursor;->isLast()Z

    move-result v8

    if-nez v8, :cond_3

    invoke-interface {v6}, Landroid/database/Cursor;->isAfterLast()Z

    move-result v6
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-nez v6, :cond_3

    const/4 v6, 0x1

    goto :goto_1

    :cond_3
    const/4 v6, 0x0

    :goto_1
    if-eqz v6, :cond_4

    :try_start_1
    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-interface {v7, v0, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    :cond_4
    invoke-interface {p1, v7}, Lt/f;->a(Ljava/lang/Object;)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    if-nez v6, :cond_5

    invoke-direct {p0, v2}, Lr/i;->m(Lr/t;)V

    :cond_5
    return v4

    :catch_0
    move-exception v0

    goto :goto_2

    :catchall_0
    move-exception p1

    goto :goto_4

    :catch_1
    move-exception v0

    const/4 v6, 0x0

    goto :goto_2

    :cond_6
    :try_start_2
    new-instance v0, Ljava/lang/IllegalStateException;

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "Cursor "

    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, " not found"

    invoke-virtual {v4, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_1
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    :goto_2
    :try_start_3
    invoke-virtual {p0, v0, p1}, Lr/i;->D(Ljava/lang/Exception;Lt/e;)V

    if-eqz v2, :cond_7

    invoke-direct {p0, v2}, Lr/i;->m(Lr/t;)V
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_1

    goto :goto_3

    :cond_7
    move-object v3, v2

    :goto_3
    if-nez v6, :cond_8

    if-eqz v3, :cond_8

    invoke-direct {p0, v3}, Lr/i;->m(Lr/t;)V

    :cond_8
    return v5

    :catchall_1
    move-exception p1

    move v5, v6

    :goto_4
    if-nez v5, :cond_9

    if-eqz v2, :cond_9

    invoke-direct {p0, v2}, Lr/i;->m(Lr/t;)V

    :cond_9
    throw p1
.end method

.method private t(Lt/e;)Z
    .locals 7

    invoke-direct {p0, p1}, Lr/i;->w(Lt/e;)Z

    move-result v0

    const/4 v1, 0x0

    if-nez v0, :cond_0

    return v1

    :cond_0
    invoke-interface {p1}, Lt/e;->e()Z

    move-result v0

    const/4 v2, 0x1

    const/4 v3, 0x0

    if-eqz v0, :cond_1

    invoke-interface {p1, v3}, Lt/f;->a(Ljava/lang/Object;)V

    return v2

    :cond_1
    :try_start_0
    invoke-virtual {p0}, Lr/i;->C()Landroid/database/sqlite/SQLiteDatabase;

    move-result-object v0

    const-string v4, "SELECT changes()"

    invoke-virtual {v0, v4, v3}, Landroid/database/sqlite/SQLiteDatabase;->rawQuery(Ljava/lang/String;[Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1
    .catchall {:try_start_0 .. :try_end_0} :catchall_1

    const-string v4, "Sqflite"

    if-eqz v0, :cond_3

    :try_start_1
    invoke-interface {v0}, Landroid/database/Cursor;->getCount()I

    move-result v5

    if-lez v5, :cond_3

    invoke-interface {v0}, Landroid/database/Cursor;->moveToFirst()Z

    move-result v5

    if-eqz v5, :cond_3

    invoke-interface {v0, v1}, Landroid/database/Cursor;->getInt(I)I

    move-result v3

    iget v5, p0, Lr/i;->d:I

    invoke-static {v5}, Lr/r;->b(I)Z

    move-result v5

    if-eqz v5, :cond_2

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p0}, Lr/i;->A()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v6, "changed "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v4, v5}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    :cond_2
    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    invoke-interface {p1, v3}, Lt/f;->a(Ljava/lang/Object;)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    invoke-interface {v0}, Landroid/database/Cursor;->close()V

    return v2

    :catchall_0
    move-exception p1

    move-object v3, v0

    goto :goto_1

    :catch_0
    move-exception v2

    move-object v3, v0

    goto :goto_0

    :cond_3
    :try_start_2
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p0}, Lr/i;->A()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v6, "fail to read changes for Update/Delete"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v4, v5}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    invoke-interface {p1, v3}, Lt/f;->a(Ljava/lang/Object;)V
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_0
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    if-eqz v0, :cond_4

    invoke-interface {v0}, Landroid/database/Cursor;->close()V

    :cond_4
    return v2

    :catchall_1
    move-exception p1

    goto :goto_1

    :catch_1
    move-exception v2

    :goto_0
    :try_start_3
    invoke-virtual {p0, v2, p1}, Lr/i;->D(Ljava/lang/Exception;Lt/e;)V
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_1

    if-eqz v3, :cond_5

    invoke-interface {v3}, Landroid/database/Cursor;->close()V

    :cond_5
    return v1

    :goto_1
    if-eqz v3, :cond_6

    invoke-interface {v3}, Landroid/database/Cursor;->close()V

    :cond_6
    throw p1
.end method

.method private w(Lt/e;)Z
    .locals 4

    invoke-interface {p1}, Lt/e;->d()Lr/d0;

    move-result-object v0

    iget v1, p0, Lr/i;->d:I

    invoke-static {v1}, Lr/r;->b(I)Z

    move-result v1

    if-eqz v1, :cond_0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p0}, Lr/i;->A()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    const-string v2, "Sqflite"

    invoke-static {v2, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    :cond_0
    invoke-interface {p1}, Lt/e;->f()Ljava/lang/Boolean;

    move-result-object v1

    :try_start_0
    invoke-virtual {p0}, Lr/i;->C()Landroid/database/sqlite/SQLiteDatabase;

    move-result-object v2

    invoke-virtual {v0}, Lr/d0;->c()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v0}, Lr/d0;->d()[Ljava/lang/Object;

    move-result-object v0

    invoke-virtual {v2, v3, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;[Ljava/lang/Object;)V

    invoke-virtual {p0, v1}, Lr/i;->u(Ljava/lang/Boolean;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    const/4 p1, 0x1

    return p1

    :catch_0
    move-exception v0

    invoke-virtual {p0, v0, p1}, Lr/i;->D(Ljava/lang/Exception;Lt/e;)V

    const/4 p1, 0x0

    return p1
.end method

.method public static x(Ljava/lang/String;)Z
    .locals 1

    :try_start_0
    new-instance v0, Ljava/io/File;

    invoke-direct {v0, p0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result p0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    const/4 p0, 0x0

    :goto_0
    return p0
.end method

.method static y(Landroid/content/Context;Ljava/lang/String;I)Landroid/content/pm/ApplicationInfo;
    .locals 0

    invoke-virtual {p0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object p0

    invoke-virtual {p0, p1, p2}, Landroid/content/pm/PackageManager;->getApplicationInfo(Ljava/lang/String;I)Landroid/content/pm/ApplicationInfo;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method A()Ljava/lang/String;
    .locals 2

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "["

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p0}, Lr/i;->B()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, "] "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method B()Ljava/lang/String;
    .locals 4

    invoke-static {}, Ljava/lang/Thread;->currentThread()Ljava/lang/Thread;

    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    iget v2, p0, Lr/i;->c:I

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, ","

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/Thread;->getName()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v2, "("

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/Thread;->getId()J

    move-result-wide v2

    invoke-virtual {v1, v2, v3}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    const-string v0, ")"

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public C()Landroid/database/sqlite/SQLiteDatabase;
    .locals 1

    iget-object v0, p0, Lr/i;->i:Landroid/database/sqlite/SQLiteDatabase;

    return-object v0
.end method

.method D(Ljava/lang/Exception;Lt/e;)V
    .locals 2

    instance-of v0, p1, Landroid/database/sqlite/SQLiteCantOpenDatabaseException;

    const-string v1, "sqlite_error"

    if-eqz v0, :cond_0

    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v0, "open_failed "

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v0, p0, Lr/i;->b:Ljava/lang/String;

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    const/4 v0, 0x0

    :goto_0
    invoke-interface {p2, v1, p1, v0}, Lt/f;->b(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V

    return-void

    :cond_0
    instance-of v0, p1, Landroid/database/SQLException;

    invoke-virtual {p1}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    move-result-object p1

    invoke-static {p2}, Lt/h;->a(Lt/e;)Ljava/util/Map;

    move-result-object v0

    goto :goto_0
.end method

.method public E(Lt/e;)V
    .locals 1

    new-instance v0, Lr/d;

    invoke-direct {v0, p0, p1}, Lr/d;-><init>(Lr/i;Lt/e;)V

    invoke-direct {p0, p1, v0}, Lr/i;->S(Lt/e;Ljava/lang/Runnable;)V

    return-void
.end method

.method declared-synchronized F()Z
    .locals 1

    monitor-enter p0

    :try_start_0
    iget v0, p0, Lr/i;->j:I
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-lez v0, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    monitor-exit p0

    return v0

    :catchall_0
    move-exception v0

    monitor-exit p0

    throw v0
.end method

.method public M()V
    .locals 3

    sget-object v0, Lr/i;->n:Ljava/lang/Boolean;

    if-nez v0, :cond_0

    iget-object v0, p0, Lr/i;->e:Landroid/content/Context;

    invoke-static {v0}, Lr/i;->j(Landroid/content/Context;)Z

    move-result v0

    invoke-static {v0}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v0

    sput-object v0, Lr/i;->n:Ljava/lang/Boolean;

    invoke-virtual {v0}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v0

    if-eqz v0, :cond_0

    iget v0, p0, Lr/i;->d:I

    invoke-static {v0}, Lr/r;->c(I)Z

    move-result v0

    if-eqz v0, :cond_0

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p0}, Lr/i;->A()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, "[sqflite] WAL enabled"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "Sqflite"

    invoke-static {v1, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    :cond_0
    sget-object v0, Lr/i;->n:Ljava/lang/Boolean;

    invoke-virtual {v0}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v0

    if-eqz v0, :cond_1

    const/high16 v0, 0x30000000

    goto :goto_0

    :cond_1
    const/high16 v0, 0x10000000

    :goto_0
    iget-object v1, p0, Lr/i;->b:Ljava/lang/String;

    const/4 v2, 0x0

    invoke-static {v1, v2, v0}, Landroid/database/sqlite/SQLiteDatabase;->openDatabase(Ljava/lang/String;Landroid/database/sqlite/SQLiteDatabase$CursorFactory;I)Landroid/database/sqlite/SQLiteDatabase;

    move-result-object v0

    iput-object v0, p0, Lr/i;->i:Landroid/database/sqlite/SQLiteDatabase;

    return-void
.end method

.method public N()V
    .locals 4

    iget-object v0, p0, Lr/i;->b:Ljava/lang/String;

    new-instance v1, Lr/i$a;

    invoke-direct {v1, p0}, Lr/i$a;-><init>(Lr/i;)V

    const/4 v2, 0x0

    const/4 v3, 0x1

    invoke-static {v0, v2, v3, v1}, Landroid/database/sqlite/SQLiteDatabase;->openDatabase(Ljava/lang/String;Landroid/database/sqlite/SQLiteDatabase$CursorFactory;ILandroid/database/DatabaseErrorHandler;)Landroid/database/sqlite/SQLiteDatabase;

    move-result-object v0

    iput-object v0, p0, Lr/i;->i:Landroid/database/sqlite/SQLiteDatabase;

    return-void
.end method

.method public O(Lt/e;)V
    .locals 1

    new-instance v0, Lr/e;

    invoke-direct {v0, p0, p1}, Lr/e;-><init>(Lr/i;Lt/e;)V

    invoke-direct {p0, p1, v0}, Lr/i;->S(Lt/e;Ljava/lang/Runnable;)V

    return-void
.end method

.method public P(Lt/e;)V
    .locals 1

    new-instance v0, Lr/b;

    invoke-direct {v0, p0, p1}, Lr/b;-><init>(Lr/i;Lt/e;)V

    invoke-direct {p0, p1, v0}, Lr/i;->S(Lt/e;Ljava/lang/Runnable;)V

    return-void
.end method

.method public R(Lt/e;)V
    .locals 1

    new-instance v0, Lr/g;

    invoke-direct {v0, p0, p1}, Lr/g;-><init>(Lr/i;Lt/e;)V

    invoke-direct {p0, p1, v0}, Lr/i;->S(Lt/e;Ljava/lang/Runnable;)V

    return-void
.end method

.method h(Lj0/j;Lj0/k$d;)V
    .locals 8

    new-instance v0, Lt/d;

    invoke-direct {v0, p1, p2}, Lt/d;-><init>(Lj0/j;Lj0/k$d;)V

    invoke-virtual {v0}, Lt/b;->e()Z

    move-result p1

    invoke-virtual {v0}, Lt/b;->l()Z

    move-result v1

    const-string v2, "operations"

    invoke-virtual {v0, v2}, Lt/d;->c(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/util/List;

    new-instance v2, Ljava/util/ArrayList;

    invoke-direct {v2}, Ljava/util/ArrayList;-><init>()V

    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    const/4 v4, 0x0

    if-eqz v3, :cond_c

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/util/Map;

    new-instance v5, Lt/c;

    invoke-direct {v5, v3, p1}, Lt/c;-><init>(Ljava/util/Map;Z)V

    invoke-virtual {v5}, Lt/c;->i()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/String;->hashCode()I

    const/4 v6, -0x1

    invoke-virtual {v3}, Ljava/lang/String;->hashCode()I

    move-result v7

    sparse-switch v7, :sswitch_data_0

    goto :goto_1

    :sswitch_0
    const-string v7, "query"

    invoke-virtual {v3, v7}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v7

    if-nez v7, :cond_0

    goto :goto_1

    :cond_0
    const/4 v6, 0x3

    goto :goto_1

    :sswitch_1
    const-string v7, "update"

    invoke-virtual {v3, v7}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v7

    if-nez v7, :cond_1

    goto :goto_1

    :cond_1
    const/4 v6, 0x2

    goto :goto_1

    :sswitch_2
    const-string v7, "insert"

    invoke-virtual {v3, v7}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v7

    if-nez v7, :cond_2

    goto :goto_1

    :cond_2
    const/4 v6, 0x1

    goto :goto_1

    :sswitch_3
    const-string v7, "execute"

    invoke-virtual {v3, v7}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v7

    if-nez v7, :cond_3

    goto :goto_1

    :cond_3
    const/4 v6, 0x0

    :goto_1
    packed-switch v6, :pswitch_data_0

    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v0, "Batch method \'"

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v0, "\' not supported"

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    const-string v0, "bad_param"

    invoke-interface {p2, v0, p1, v4}, Lj0/k$d;->b(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V

    return-void

    :pswitch_0
    invoke-direct {p0, v5}, Lr/i;->r(Lt/e;)Z

    move-result v3

    if-eqz v3, :cond_4

    goto :goto_3

    :cond_4
    if-eqz v1, :cond_5

    goto :goto_2

    :cond_5
    invoke-virtual {v5, p2}, Lt/c;->r(Lj0/k$d;)V

    return-void

    :pswitch_1
    invoke-direct {p0, v5}, Lr/i;->t(Lt/e;)Z

    move-result v3

    if-eqz v3, :cond_6

    goto :goto_3

    :cond_6
    if-eqz v1, :cond_7

    goto :goto_2

    :cond_7
    invoke-virtual {v5, p2}, Lt/c;->r(Lj0/k$d;)V

    return-void

    :pswitch_2
    invoke-direct {p0, v5}, Lr/i;->q(Lt/e;)Z

    move-result v3

    if-eqz v3, :cond_8

    goto :goto_3

    :cond_8
    if-eqz v1, :cond_9

    :goto_2
    goto :goto_4

    :cond_9
    invoke-virtual {v5, p2}, Lt/c;->r(Lj0/k$d;)V

    return-void

    :pswitch_3
    invoke-direct {p0, v5}, Lr/i;->p(Lt/e;)Z

    move-result v3

    if-eqz v3, :cond_a

    :goto_3
    invoke-virtual {v5, v2}, Lt/c;->t(Ljava/util/List;)V

    goto/16 :goto_0

    :cond_a
    if-eqz v1, :cond_b

    :goto_4
    invoke-virtual {v5, v2}, Lt/c;->s(Ljava/util/List;)V

    goto/16 :goto_0

    :cond_b
    invoke-virtual {v5, p2}, Lt/c;->r(Lj0/k$d;)V

    return-void

    :cond_c
    if-eqz p1, :cond_d

    invoke-interface {p2, v4}, Lj0/k$d;->a(Ljava/lang/Object;)V

    goto :goto_5

    :cond_d
    invoke-interface {p2, v2}, Lj0/k$d;->a(Ljava/lang/Object;)V

    :goto_5
    return-void

    :sswitch_data_0
    .sparse-switch
        -0x4ea7088b -> :sswitch_3
        -0x468f3d47 -> :sswitch_2
        -0x31ffc737 -> :sswitch_1
        0x66f18c8 -> :sswitch_0
    .end sparse-switch

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method public k()V
    .locals 2

    iget-object v0, p0, Lr/i;->g:Ljava/util/Map;

    invoke-interface {v0}, Ljava/util/Map;->isEmpty()Z

    move-result v0

    if-nez v0, :cond_0

    iget v0, p0, Lr/i;->d:I

    invoke-static {v0}, Lr/r;->b(I)Z

    move-result v0

    if-eqz v0, :cond_0

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p0}, Lr/i;->A()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lr/i;->g:Ljava/util/Map;

    invoke-interface {v1}, Ljava/util/Map;->size()I

    move-result v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, " cursor(s) are left opened"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "Sqflite"

    invoke-static {v1, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    :cond_0
    iget-object v0, p0, Lr/i;->i:Landroid/database/sqlite/SQLiteDatabase;

    invoke-virtual {v0}, Landroid/database/sqlite/SQLiteClosable;->close()V

    return-void
.end method

.method declared-synchronized u(Ljava/lang/Boolean;)V
    .locals 1

    monitor-enter p0

    :try_start_0
    sget-object v0, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    invoke-virtual {v0, p1}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    iget p1, p0, Lr/i;->j:I

    add-int/lit8 p1, p1, 0x1

    iput p1, p0, Lr/i;->j:I

    goto :goto_0

    :cond_0
    sget-object v0, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    invoke-virtual {v0, p1}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_1

    iget p1, p0, Lr/i;->j:I

    add-int/lit8 p1, p1, -0x1

    iput p1, p0, Lr/i;->j:I
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    :cond_1
    :goto_0
    monitor-exit p0

    return-void

    :catchall_0
    move-exception p1

    monitor-exit p0

    throw p1
.end method

.method public v(Lt/e;)V
    .locals 1

    new-instance v0, Lr/c;

    invoke-direct {v0, p0, p1}, Lr/c;-><init>(Lr/i;Lt/e;)V

    invoke-direct {p0, p1, v0}, Lr/i;->S(Lt/e;Ljava/lang/Runnable;)V

    return-void
.end method

.method public z()Landroid/database/sqlite/SQLiteDatabase;
    .locals 1

    iget-object v0, p0, Lr/i;->i:Landroid/database/sqlite/SQLiteDatabase;

    return-object v0
.end method
