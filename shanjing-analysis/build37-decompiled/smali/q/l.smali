.class final Lq/l;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lj0/k$c;


# instance fields
.field private final a:Landroid/content/Context;

.field private final b:Lq/a;

.field private final c:Lq/u;

.field private final d:Lq/z;


# direct methods
.method constructor <init>(Landroid/content/Context;Lq/a;Lq/u;Lq/z;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lq/l;->a:Landroid/content/Context;

    iput-object p2, p0, Lq/l;->b:Lq/a;

    iput-object p3, p0, Lq/l;->c:Lq/u;

    iput-object p4, p0, Lq/l;->d:Lq/z;

    return-void
.end method

.method public static synthetic a(Lj0/k$d;Ljava/lang/String;Ljava/lang/String;)V
    .locals 0

    invoke-static {p0, p1, p2}, Lq/l;->f(Lj0/k$d;Ljava/lang/String;Ljava/lang/String;)V

    return-void
.end method

.method public static synthetic b(Lj0/k$d;Ljava/lang/String;Ljava/lang/String;)V
    .locals 0

    invoke-static {p0, p1, p2}, Lq/l;->e(Lj0/k$d;Ljava/lang/String;Ljava/lang/String;)V

    return-void
.end method

.method public static synthetic c(Lj0/k$d;Ljava/lang/String;Ljava/lang/String;)V
    .locals 0

    invoke-static {p0, p1, p2}, Lq/l;->i(Lj0/k$d;Ljava/lang/String;Ljava/lang/String;)V

    return-void
.end method

.method public static synthetic d(Lj0/k$d;Ljava/lang/String;Ljava/lang/String;)V
    .locals 0

    invoke-static {p0, p1, p2}, Lq/l;->g(Lj0/k$d;Ljava/lang/String;Ljava/lang/String;)V

    return-void
.end method

.method private static synthetic e(Lj0/k$d;Ljava/lang/String;Ljava/lang/String;)V
    .locals 1

    const/4 v0, 0x0

    invoke-interface {p0, p1, p2, v0}, Lj0/k$d;->b(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V

    return-void
.end method

.method private static synthetic f(Lj0/k$d;Ljava/lang/String;Ljava/lang/String;)V
    .locals 1

    const/4 v0, 0x0

    invoke-interface {p0, p1, p2, v0}, Lj0/k$d;->b(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V

    return-void
.end method

.method private static synthetic g(Lj0/k$d;Ljava/lang/String;Ljava/lang/String;)V
    .locals 1

    const/4 v0, 0x0

    invoke-interface {p0, p1, p2, v0}, Lj0/k$d;->b(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V

    return-void
.end method

.method private static synthetic i(Lj0/k$d;Ljava/lang/String;Ljava/lang/String;)V
    .locals 1

    const/4 v0, 0x0

    invoke-interface {p0, p1, p2, v0}, Lj0/k$d;->b(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V

    return-void
.end method


# virtual methods
.method public h(Lj0/j;Lj0/k$d;)V
    .locals 4

    iget-object v0, p1, Lj0/j;->a:Ljava/lang/String;

    invoke-virtual {v0}, Ljava/lang/String;->hashCode()I

    invoke-virtual {v0}, Ljava/lang/String;->hashCode()I

    move-result v1

    const/4 v2, -0x1

    sparse-switch v1, :sswitch_data_0

    goto :goto_0

    :sswitch_0
    const-string v1, "requestPermissions"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_0

    goto :goto_0

    :cond_0
    const/4 v2, 0x4

    goto :goto_0

    :sswitch_1
    const-string v1, "openAppSettings"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_1

    goto :goto_0

    :cond_1
    const/4 v2, 0x3

    goto :goto_0

    :sswitch_2
    const-string v1, "checkPermissionStatus"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_2

    goto :goto_0

    :cond_2
    const/4 v2, 0x2

    goto :goto_0

    :sswitch_3
    const-string v1, "shouldShowRequestPermissionRationale"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_3

    goto :goto_0

    :cond_3
    const/4 v2, 0x1

    goto :goto_0

    :sswitch_4
    const-string v1, "checkServiceStatus"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_4

    goto :goto_0

    :cond_4
    const/4 v2, 0x0

    :goto_0
    packed-switch v2, :pswitch_data_0

    invoke-interface {p2}, Lj0/k$d;->c()V

    goto/16 :goto_1

    :pswitch_0
    invoke-virtual {p1}, Lj0/j;->b()Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/util/List;

    iget-object v0, p0, Lq/l;->c:Lq/u;

    invoke-static {p2}, Ljava/util/Objects;->requireNonNull(Ljava/lang/Object;)Ljava/lang/Object;

    new-instance v1, Lq/f;

    invoke-direct {v1, p2}, Lq/f;-><init>(Lj0/k$d;)V

    new-instance v2, Lq/g;

    invoke-direct {v2, p2}, Lq/g;-><init>(Lj0/k$d;)V

    invoke-virtual {v0, p1, v1, v2}, Lq/u;->i(Ljava/util/List;Lq/u$b;Lq/b;)V

    goto :goto_1

    :pswitch_1
    iget-object p1, p0, Lq/l;->b:Lq/a;

    iget-object v0, p0, Lq/l;->a:Landroid/content/Context;

    invoke-static {p2}, Ljava/util/Objects;->requireNonNull(Ljava/lang/Object;)Ljava/lang/Object;

    new-instance v1, Lq/j;

    invoke-direct {v1, p2}, Lq/j;-><init>(Lj0/k$d;)V

    new-instance v2, Lq/k;

    invoke-direct {v2, p2}, Lq/k;-><init>(Lj0/k$d;)V

    invoke-virtual {p1, v0, v1, v2}, Lq/a;->a(Landroid/content/Context;Lq/a$a;Lq/b;)V

    goto :goto_1

    :pswitch_2
    iget-object p1, p1, Lj0/j;->b:Ljava/lang/Object;

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p1}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result p1

    iget-object v0, p0, Lq/l;->c:Lq/u;

    invoke-static {p2}, Ljava/util/Objects;->requireNonNull(Ljava/lang/Object;)Ljava/lang/Object;

    new-instance v1, Lq/e;

    invoke-direct {v1, p2}, Lq/e;-><init>(Lj0/k$d;)V

    invoke-virtual {v0, p1, v1}, Lq/u;->e(ILq/u$a;)V

    goto :goto_1

    :pswitch_3
    iget-object p1, p1, Lj0/j;->b:Ljava/lang/Object;

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p1}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result p1

    iget-object v0, p0, Lq/l;->c:Lq/u;

    invoke-static {p2}, Ljava/util/Objects;->requireNonNull(Ljava/lang/Object;)Ljava/lang/Object;

    new-instance v1, Lq/h;

    invoke-direct {v1, p2}, Lq/h;-><init>(Lj0/k$d;)V

    new-instance v2, Lq/i;

    invoke-direct {v2, p2}, Lq/i;-><init>(Lj0/k$d;)V

    invoke-virtual {v0, p1, v1, v2}, Lq/u;->k(ILq/u$c;Lq/b;)V

    goto :goto_1

    :pswitch_4
    iget-object p1, p1, Lj0/j;->b:Ljava/lang/Object;

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p1}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result p1

    iget-object v0, p0, Lq/l;->d:Lq/z;

    iget-object v1, p0, Lq/l;->a:Landroid/content/Context;

    invoke-static {p2}, Ljava/util/Objects;->requireNonNull(Ljava/lang/Object;)Ljava/lang/Object;

    new-instance v2, Lq/c;

    invoke-direct {v2, p2}, Lq/c;-><init>(Lj0/k$d;)V

    new-instance v3, Lq/d;

    invoke-direct {v3, p2}, Lq/d;-><init>(Lj0/k$d;)V

    invoke-virtual {v0, p1, v1, v2, v3}, Lq/z;->a(ILandroid/content/Context;Lq/z$a;Lq/b;)V

    :goto_1
    return-void

    :sswitch_data_0
    .sparse-switch
        -0x5c086121 -> :sswitch_4
        -0x3ca2ffb7 -> :sswitch_3
        -0x22583c37 -> :sswitch_2
        0x14b278ba -> :sswitch_1
        0x637dca75 -> :sswitch_0
    .end sparse-switch

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_4
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method
