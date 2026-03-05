.class public Li/a;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lb0/a;
.implements Lj0/k$c;
.implements Lj0/d$d;


# static fields
.field public static c:Lj0/d$b;


# instance fields
.field private a:Landroid/content/Context;

.field private b:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Li/b;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method static constructor <clinit>()V
    .locals 0

    return-void
.end method

.method public constructor <init>()V
    .locals 2

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    const/4 v0, 0x0

    iput-object v0, p0, Li/a;->a:Landroid/content/Context;

    new-instance v0, Ljava/util/concurrent/ConcurrentHashMap;

    const/16 v1, 0x8

    invoke-direct {v0, v1}, Ljava/util/concurrent/ConcurrentHashMap;-><init>(I)V

    iput-object v0, p0, Li/a;->b:Ljava/util/Map;

    return-void
.end method

.method private d(Ljava/util/Map;)V
    .locals 1

    invoke-direct {p0, p1}, Li/a;->e(Ljava/util/Map;)Li/b;

    move-result-object v0

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Li/b;->a()V

    iget-object v0, p0, Li/a;->b:Ljava/util/Map;

    invoke-direct {p0, p1}, Li/a;->f(Ljava/util/Map;)Ljava/lang/String;

    move-result-object p1

    invoke-interface {v0, p1}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    :cond_0
    return-void
.end method

.method private e(Ljava/util/Map;)Li/b;
    .locals 3

    iget-object v0, p0, Li/a;->b:Ljava/util/Map;

    if-nez v0, :cond_0

    new-instance v0, Ljava/util/concurrent/ConcurrentHashMap;

    const/16 v1, 0x8

    invoke-direct {v0, v1}, Ljava/util/concurrent/ConcurrentHashMap;-><init>(I)V

    iput-object v0, p0, Li/a;->b:Ljava/util/Map;

    :cond_0
    invoke-direct {p0, p1}, Li/a;->f(Ljava/util/Map;)Ljava/lang/String;

    move-result-object p1

    invoke-static {p1}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v0

    if-eqz v0, :cond_1

    const/4 p1, 0x0

    return-object p1

    :cond_1
    iget-object v0, p0, Li/a;->b:Ljava/util/Map;

    invoke-interface {v0, p1}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_2

    new-instance v0, Li/b;

    iget-object v1, p0, Li/a;->a:Landroid/content/Context;

    sget-object v2, Li/a;->c:Lj0/d$b;

    invoke-direct {v0, v1, p1, v2}, Li/b;-><init>(Landroid/content/Context;Ljava/lang/String;Lj0/d$b;)V

    iget-object v1, p0, Li/a;->b:Ljava/util/Map;

    invoke-interface {v1, p1, v0}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    :cond_2
    iget-object v0, p0, Li/a;->b:Ljava/util/Map;

    invoke-interface {v0, p1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Li/b;

    return-object p1
.end method

.method private f(Ljava/util/Map;)Ljava/lang/String;
    .locals 2

    const/4 v0, 0x0

    if-eqz p1, :cond_0

    :try_start_0
    const-string v1, "pluginKey"

    invoke-interface {p1, v1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/String;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    move-object v0, p1

    goto :goto_0

    :catchall_0
    move-exception p1

    invoke-virtual {p1}, Ljava/lang/Throwable;->printStackTrace()V

    :cond_0
    :goto_0
    return-object v0
.end method

.method private g(Ljava/util/Map;)V
    .locals 2

    if-eqz p1, :cond_0

    const-string v0, "android"

    invoke-interface {p1, v0}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    invoke-interface {p1, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/String;

    invoke-static {v1}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v1

    if-nez v1, :cond_0

    invoke-interface {p1, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/String;

    invoke-static {p1}, Lcom/amap/api/location/AMapLocationClient;->setApiKey(Ljava/lang/String;)V

    :cond_0
    return-void
.end method

.method private j(Ljava/util/Map;)V
    .locals 1

    invoke-direct {p0, p1}, Li/a;->e(Ljava/util/Map;)Li/b;

    move-result-object v0

    if-eqz v0, :cond_0

    invoke-virtual {v0, p1}, Li/b;->b(Ljava/util/Map;)V

    :cond_0
    return-void
.end method

.method private k(Ljava/util/Map;)V
    .locals 0

    invoke-direct {p0, p1}, Li/a;->e(Ljava/util/Map;)Li/b;

    move-result-object p1

    if-eqz p1, :cond_0

    invoke-virtual {p1}, Li/b;->c()V

    :cond_0
    return-void
.end method

.method private l(Ljava/util/Map;)V
    .locals 0

    invoke-direct {p0, p1}, Li/a;->e(Ljava/util/Map;)Li/b;

    move-result-object p1

    if-eqz p1, :cond_0

    invoke-virtual {p1}, Li/b;->d()V

    :cond_0
    return-void
.end method

.method private m(Ljava/util/Map;)V
    .locals 11

    if-eqz p1, :cond_1

    const-class v0, Lcom/amap/api/location/AMapLocationClient;

    const-string v1, "hasContains"

    invoke-interface {p1, v1}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v2

    const/4 v3, 0x0

    const/4 v4, 0x1

    const/4 v5, 0x0

    const/4 v6, 0x2

    if-eqz v2, :cond_0

    const-string v2, "hasShow"

    invoke-interface {p1, v2}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v7

    if-eqz v7, :cond_0

    invoke-interface {p1, v1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Boolean;

    invoke-virtual {v1}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v1

    invoke-interface {p1, v2}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/Boolean;

    invoke-virtual {v2}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v2

    :try_start_0
    const-string v7, "updatePrivacyShow"

    const/4 v8, 0x3

    new-array v9, v8, [Ljava/lang/Class;

    const-class v10, Landroid/content/Context;

    aput-object v10, v9, v5

    sget-object v10, Ljava/lang/Boolean;->TYPE:Ljava/lang/Class;

    aput-object v10, v9, v4

    aput-object v10, v9, v6

    invoke-virtual {v0, v7, v9}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v7

    new-array v8, v8, [Ljava/lang/Object;

    iget-object v9, p0, Li/a;->a:Landroid/content/Context;

    aput-object v9, v8, v5

    invoke-static {v1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v1

    aput-object v1, v8, v4

    invoke-static {v2}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v1

    aput-object v1, v8, v6

    invoke-virtual {v7, v3, v8}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    nop

    :cond_0
    :goto_0
    const-string v1, "hasAgree"

    invoke-interface {p1, v1}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_1

    invoke-interface {p1, v1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/Boolean;

    invoke-virtual {p1}, Ljava/lang/Boolean;->booleanValue()Z

    move-result p1

    :try_start_1
    const-string v1, "updatePrivacyAgree"

    new-array v2, v6, [Ljava/lang/Class;

    const-class v7, Landroid/content/Context;

    aput-object v7, v2, v5

    sget-object v7, Ljava/lang/Boolean;->TYPE:Ljava/lang/Class;

    aput-object v7, v2, v4

    invoke-virtual {v0, v1, v2}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    new-array v1, v6, [Ljava/lang/Object;

    iget-object v2, p0, Li/a;->a:Landroid/content/Context;

    aput-object v2, v1, v5

    invoke-static {p1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object p1

    aput-object p1, v1, v4

    invoke-virtual {v0, v3, v1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    :catchall_1
    :cond_1
    return-void
.end method


# virtual methods
.method public a(Lb0/a$b;)V
    .locals 1

    iget-object p1, p0, Li/a;->b:Ljava/util/Map;

    invoke-interface {p1}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object p1

    invoke-interface {p1}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object p1

    :goto_0
    invoke-interface {p1}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_0

    invoke-interface {p1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/util/Map$Entry;

    invoke-interface {v0}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Li/b;

    invoke-virtual {v0}, Li/b;->a()V

    goto :goto_0

    :cond_0
    return-void
.end method

.method public b(Ljava/lang/Object;)V
    .locals 1

    iget-object p1, p0, Li/a;->b:Ljava/util/Map;

    invoke-interface {p1}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object p1

    invoke-interface {p1}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object p1

    :goto_0
    invoke-interface {p1}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_0

    invoke-interface {p1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/util/Map$Entry;

    invoke-interface {v0}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Li/b;

    invoke-virtual {v0}, Li/b;->d()V

    goto :goto_0

    :cond_0
    return-void
.end method

.method public c(Ljava/lang/Object;Lj0/d$b;)V
    .locals 0

    sput-object p2, Li/a;->c:Lj0/d$b;

    return-void
.end method

.method public h(Lj0/j;Lj0/k$d;)V
    .locals 3

    iget-object v0, p1, Lj0/j;->a:Ljava/lang/String;

    invoke-virtual {v0}, Ljava/lang/String;->hashCode()I

    invoke-virtual {v0}, Ljava/lang/String;->hashCode()I

    move-result v1

    const/4 v2, -0x1

    sparse-switch v1, :sswitch_data_0

    goto :goto_0

    :sswitch_0
    const-string v1, "startLocation"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_0

    goto :goto_0

    :cond_0
    const/4 v2, 0x5

    goto :goto_0

    :sswitch_1
    const-string v1, "destroy"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_1

    goto :goto_0

    :cond_1
    const/4 v2, 0x4

    goto :goto_0

    :sswitch_2
    const-string v1, "updatePrivacyStatement"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_2

    goto :goto_0

    :cond_2
    const/4 v2, 0x3

    goto :goto_0

    :sswitch_3
    const-string v1, "stopLocation"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_3

    goto :goto_0

    :cond_3
    const/4 v2, 0x2

    goto :goto_0

    :sswitch_4
    const-string v1, "setApiKey"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_4

    goto :goto_0

    :cond_4
    const/4 v2, 0x1

    goto :goto_0

    :sswitch_5
    const-string v1, "setLocationOption"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_5

    goto :goto_0

    :cond_5
    const/4 v2, 0x0

    :goto_0
    packed-switch v2, :pswitch_data_0

    invoke-interface {p2}, Lj0/k$d;->c()V

    goto :goto_1

    :pswitch_0
    iget-object p1, p1, Lj0/j;->b:Ljava/lang/Object;

    check-cast p1, Ljava/util/Map;

    invoke-direct {p0, p1}, Li/a;->k(Ljava/util/Map;)V

    goto :goto_1

    :pswitch_1
    iget-object p1, p1, Lj0/j;->b:Ljava/lang/Object;

    check-cast p1, Ljava/util/Map;

    invoke-direct {p0, p1}, Li/a;->d(Ljava/util/Map;)V

    goto :goto_1

    :pswitch_2
    iget-object p1, p1, Lj0/j;->b:Ljava/lang/Object;

    check-cast p1, Ljava/util/Map;

    invoke-direct {p0, p1}, Li/a;->m(Ljava/util/Map;)V

    goto :goto_1

    :pswitch_3
    iget-object p1, p1, Lj0/j;->b:Ljava/lang/Object;

    check-cast p1, Ljava/util/Map;

    invoke-direct {p0, p1}, Li/a;->l(Ljava/util/Map;)V

    goto :goto_1

    :pswitch_4
    iget-object p1, p1, Lj0/j;->b:Ljava/lang/Object;

    check-cast p1, Ljava/util/Map;

    invoke-direct {p0, p1}, Li/a;->g(Ljava/util/Map;)V

    goto :goto_1

    :pswitch_5
    iget-object p1, p1, Lj0/j;->b:Ljava/lang/Object;

    check-cast p1, Ljava/util/Map;

    invoke-direct {p0, p1}, Li/a;->j(Ljava/util/Map;)V

    :goto_1
    return-void

    :sswitch_data_0
    .sparse-switch
        -0x5c9e1274 -> :sswitch_5
        0x42d94e7 -> :sswitch_4
        0x2b60e9d7 -> :sswitch_3
        0x523769b0 -> :sswitch_2
        0x5cd39ffa -> :sswitch_1
        0x78e34637 -> :sswitch_0
    .end sparse-switch

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_5
        :pswitch_4
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method public i(Lb0/a$b;)V
    .locals 3

    iget-object v0, p0, Li/a;->a:Landroid/content/Context;

    if-nez v0, :cond_0

    invoke-virtual {p1}, Lb0/a$b;->a()Landroid/content/Context;

    move-result-object v0

    iput-object v0, p0, Li/a;->a:Landroid/content/Context;

    new-instance v0, Lj0/k;

    invoke-virtual {p1}, Lb0/a$b;->b()Lj0/c;

    move-result-object v1

    const-string v2, "amap_flutter_location"

    invoke-direct {v0, v1, v2}, Lj0/k;-><init>(Lj0/c;Ljava/lang/String;)V

    invoke-virtual {v0, p0}, Lj0/k;->e(Lj0/k$c;)V

    new-instance v0, Lj0/d;

    invoke-virtual {p1}, Lb0/a$b;->b()Lj0/c;

    move-result-object p1

    const-string v1, "amap_flutter_location_stream"

    invoke-direct {v0, p1, v1}, Lj0/d;-><init>(Lj0/c;Ljava/lang/String;)V

    invoke-virtual {v0, p0}, Lj0/d;->d(Lj0/d$d;)V

    :cond_0
    return-void
.end method
