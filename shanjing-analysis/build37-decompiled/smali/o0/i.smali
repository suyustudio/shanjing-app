.class public final synthetic Lo0/i;
.super Ljava/lang/Object;
.source "SourceFile"


# direct methods
.method public static a()Lj0/i;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Lj0/i<",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation

    new-instance v0, Lj0/q;

    invoke-direct {v0}, Lj0/q;-><init>()V

    return-object v0
.end method

.method public static synthetic b(Lo0/a$b;Ljava/lang/Object;Lj0/a$e;)V
    .locals 1

    new-instance p1, Ljava/util/ArrayList;

    invoke-direct {p1}, Ljava/util/ArrayList;-><init>()V

    :try_start_0
    invoke-interface {p0}, Lo0/a$b;->b()Ljava/lang/String;

    move-result-object p0

    const/4 v0, 0x0

    invoke-virtual {p1, v0, p0}, Ljava/util/ArrayList;->add(ILjava/lang/Object;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    move-exception p0

    invoke-static {p0}, Lo0/a;->a(Ljava/lang/Throwable;)Ljava/util/ArrayList;

    move-result-object p1

    :goto_0
    invoke-interface {p2, p1}, Lj0/a$e;->a(Ljava/lang/Object;)V

    return-void
.end method

.method public static synthetic c(Lo0/a$b;Ljava/lang/Object;Lj0/a$e;)V
    .locals 1

    new-instance p1, Ljava/util/ArrayList;

    invoke-direct {p1}, Ljava/util/ArrayList;-><init>()V

    :try_start_0
    invoke-interface {p0}, Lo0/a$b;->f()Ljava/lang/String;

    move-result-object p0

    const/4 v0, 0x0

    invoke-virtual {p1, v0, p0}, Ljava/util/ArrayList;->add(ILjava/lang/Object;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    move-exception p0

    invoke-static {p0}, Lo0/a;->a(Ljava/lang/Throwable;)Ljava/util/ArrayList;

    move-result-object p1

    :goto_0
    invoke-interface {p2, p1}, Lj0/a$e;->a(Ljava/lang/Object;)V

    return-void
.end method

.method public static synthetic d(Lo0/a$b;Ljava/lang/Object;Lj0/a$e;)V
    .locals 1

    new-instance p1, Ljava/util/ArrayList;

    invoke-direct {p1}, Ljava/util/ArrayList;-><init>()V

    :try_start_0
    invoke-interface {p0}, Lo0/a$b;->d()Ljava/lang/String;

    move-result-object p0

    const/4 v0, 0x0

    invoke-virtual {p1, v0, p0}, Ljava/util/ArrayList;->add(ILjava/lang/Object;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    move-exception p0

    invoke-static {p0}, Lo0/a;->a(Ljava/lang/Throwable;)Ljava/util/ArrayList;

    move-result-object p1

    :goto_0
    invoke-interface {p2, p1}, Lj0/a$e;->a(Ljava/lang/Object;)V

    return-void
.end method

.method public static synthetic e(Lo0/a$b;Ljava/lang/Object;Lj0/a$e;)V
    .locals 1

    new-instance p1, Ljava/util/ArrayList;

    invoke-direct {p1}, Ljava/util/ArrayList;-><init>()V

    :try_start_0
    invoke-interface {p0}, Lo0/a$b;->c()Ljava/lang/String;

    move-result-object p0

    const/4 v0, 0x0

    invoke-virtual {p1, v0, p0}, Ljava/util/ArrayList;->add(ILjava/lang/Object;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    move-exception p0

    invoke-static {p0}, Lo0/a;->a(Ljava/lang/Throwable;)Ljava/util/ArrayList;

    move-result-object p1

    :goto_0
    invoke-interface {p2, p1}, Lj0/a$e;->a(Ljava/lang/Object;)V

    return-void
.end method

.method public static synthetic f(Lo0/a$b;Ljava/lang/Object;Lj0/a$e;)V
    .locals 1

    new-instance p1, Ljava/util/ArrayList;

    invoke-direct {p1}, Ljava/util/ArrayList;-><init>()V

    :try_start_0
    invoke-interface {p0}, Lo0/a$b;->h()Ljava/lang/String;

    move-result-object p0

    const/4 v0, 0x0

    invoke-virtual {p1, v0, p0}, Ljava/util/ArrayList;->add(ILjava/lang/Object;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    move-exception p0

    invoke-static {p0}, Lo0/a;->a(Ljava/lang/Throwable;)Ljava/util/ArrayList;

    move-result-object p1

    :goto_0
    invoke-interface {p2, p1}, Lj0/a$e;->a(Ljava/lang/Object;)V

    return-void
.end method

.method public static synthetic g(Lo0/a$b;Ljava/lang/Object;Lj0/a$e;)V
    .locals 1

    new-instance p1, Ljava/util/ArrayList;

    invoke-direct {p1}, Ljava/util/ArrayList;-><init>()V

    :try_start_0
    invoke-interface {p0}, Lo0/a$b;->e()Ljava/util/List;

    move-result-object p0

    const/4 v0, 0x0

    invoke-virtual {p1, v0, p0}, Ljava/util/ArrayList;->add(ILjava/lang/Object;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    move-exception p0

    invoke-static {p0}, Lo0/a;->a(Ljava/lang/Throwable;)Ljava/util/ArrayList;

    move-result-object p1

    :goto_0
    invoke-interface {p2, p1}, Lj0/a$e;->a(Ljava/lang/Object;)V

    return-void
.end method

.method public static synthetic h(Lo0/a$b;Ljava/lang/Object;Lj0/a$e;)V
    .locals 3

    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    check-cast p1, Ljava/util/ArrayList;

    const/4 v1, 0x0

    invoke-virtual {p1, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v2

    if-nez v2, :cond_0

    const/4 p1, 0x0

    goto :goto_0

    :cond_0
    invoke-static {}, Lo0/a$c;->values()[Lo0/a$c;

    move-result-object v2

    invoke-virtual {p1, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/Integer;

    invoke-virtual {p1}, Ljava/lang/Integer;->intValue()I

    move-result p1

    aget-object p1, v2, p1

    :goto_0
    :try_start_0
    invoke-interface {p0, p1}, Lo0/a$b;->g(Lo0/a$c;)Ljava/util/List;

    move-result-object p0

    invoke-virtual {v0, v1, p0}, Ljava/util/ArrayList;->add(ILjava/lang/Object;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_1

    :catchall_0
    move-exception p0

    invoke-static {p0}, Lo0/a;->a(Ljava/lang/Throwable;)Ljava/util/ArrayList;

    move-result-object v0

    :goto_1
    invoke-interface {p2, v0}, Lj0/a$e;->a(Ljava/lang/Object;)V

    return-void
.end method

.method public static i(Lj0/c;Lo0/a$b;)V
    .locals 5

    invoke-interface {p0}, Lj0/c;->c()Lj0/c$c;

    move-result-object v0

    new-instance v1, Lj0/a;

    invoke-static {}, Lo0/i;->a()Lj0/i;

    move-result-object v2

    const-string v3, "dev.flutter.pigeon.PathProviderApi.getTemporaryPath"

    invoke-direct {v1, p0, v3, v2, v0}, Lj0/a;-><init>(Lj0/c;Ljava/lang/String;Lj0/i;Lj0/c$c;)V

    const/4 v0, 0x0

    if-eqz p1, :cond_0

    new-instance v2, Lo0/b;

    invoke-direct {v2, p1}, Lo0/b;-><init>(Lo0/a$b;)V

    invoke-virtual {v1, v2}, Lj0/a;->e(Lj0/a$d;)V

    goto :goto_0

    :cond_0
    invoke-virtual {v1, v0}, Lj0/a;->e(Lj0/a$d;)V

    :goto_0
    invoke-interface {p0}, Lj0/c;->c()Lj0/c$c;

    move-result-object v1

    new-instance v2, Lj0/a;

    invoke-static {}, Lo0/i;->a()Lj0/i;

    move-result-object v3

    const-string v4, "dev.flutter.pigeon.PathProviderApi.getApplicationSupportPath"

    invoke-direct {v2, p0, v4, v3, v1}, Lj0/a;-><init>(Lj0/c;Ljava/lang/String;Lj0/i;Lj0/c$c;)V

    if-eqz p1, :cond_1

    new-instance v1, Lo0/c;

    invoke-direct {v1, p1}, Lo0/c;-><init>(Lo0/a$b;)V

    invoke-virtual {v2, v1}, Lj0/a;->e(Lj0/a$d;)V

    goto :goto_1

    :cond_1
    invoke-virtual {v2, v0}, Lj0/a;->e(Lj0/a$d;)V

    :goto_1
    invoke-interface {p0}, Lj0/c;->c()Lj0/c$c;

    move-result-object v1

    new-instance v2, Lj0/a;

    invoke-static {}, Lo0/i;->a()Lj0/i;

    move-result-object v3

    const-string v4, "dev.flutter.pigeon.PathProviderApi.getApplicationDocumentsPath"

    invoke-direct {v2, p0, v4, v3, v1}, Lj0/a;-><init>(Lj0/c;Ljava/lang/String;Lj0/i;Lj0/c$c;)V

    if-eqz p1, :cond_2

    new-instance v1, Lo0/d;

    invoke-direct {v1, p1}, Lo0/d;-><init>(Lo0/a$b;)V

    invoke-virtual {v2, v1}, Lj0/a;->e(Lj0/a$d;)V

    goto :goto_2

    :cond_2
    invoke-virtual {v2, v0}, Lj0/a;->e(Lj0/a$d;)V

    :goto_2
    invoke-interface {p0}, Lj0/c;->c()Lj0/c$c;

    move-result-object v1

    new-instance v2, Lj0/a;

    invoke-static {}, Lo0/i;->a()Lj0/i;

    move-result-object v3

    const-string v4, "dev.flutter.pigeon.PathProviderApi.getApplicationCachePath"

    invoke-direct {v2, p0, v4, v3, v1}, Lj0/a;-><init>(Lj0/c;Ljava/lang/String;Lj0/i;Lj0/c$c;)V

    if-eqz p1, :cond_3

    new-instance v1, Lo0/e;

    invoke-direct {v1, p1}, Lo0/e;-><init>(Lo0/a$b;)V

    invoke-virtual {v2, v1}, Lj0/a;->e(Lj0/a$d;)V

    goto :goto_3

    :cond_3
    invoke-virtual {v2, v0}, Lj0/a;->e(Lj0/a$d;)V

    :goto_3
    invoke-interface {p0}, Lj0/c;->c()Lj0/c$c;

    move-result-object v1

    new-instance v2, Lj0/a;

    invoke-static {}, Lo0/i;->a()Lj0/i;

    move-result-object v3

    const-string v4, "dev.flutter.pigeon.PathProviderApi.getExternalStoragePath"

    invoke-direct {v2, p0, v4, v3, v1}, Lj0/a;-><init>(Lj0/c;Ljava/lang/String;Lj0/i;Lj0/c$c;)V

    if-eqz p1, :cond_4

    new-instance v1, Lo0/f;

    invoke-direct {v1, p1}, Lo0/f;-><init>(Lo0/a$b;)V

    invoke-virtual {v2, v1}, Lj0/a;->e(Lj0/a$d;)V

    goto :goto_4

    :cond_4
    invoke-virtual {v2, v0}, Lj0/a;->e(Lj0/a$d;)V

    :goto_4
    invoke-interface {p0}, Lj0/c;->c()Lj0/c$c;

    move-result-object v1

    new-instance v2, Lj0/a;

    invoke-static {}, Lo0/i;->a()Lj0/i;

    move-result-object v3

    const-string v4, "dev.flutter.pigeon.PathProviderApi.getExternalCachePaths"

    invoke-direct {v2, p0, v4, v3, v1}, Lj0/a;-><init>(Lj0/c;Ljava/lang/String;Lj0/i;Lj0/c$c;)V

    if-eqz p1, :cond_5

    new-instance v1, Lo0/g;

    invoke-direct {v1, p1}, Lo0/g;-><init>(Lo0/a$b;)V

    invoke-virtual {v2, v1}, Lj0/a;->e(Lj0/a$d;)V

    goto :goto_5

    :cond_5
    invoke-virtual {v2, v0}, Lj0/a;->e(Lj0/a$d;)V

    :goto_5
    invoke-interface {p0}, Lj0/c;->c()Lj0/c$c;

    move-result-object v1

    new-instance v2, Lj0/a;

    invoke-static {}, Lo0/i;->a()Lj0/i;

    move-result-object v3

    const-string v4, "dev.flutter.pigeon.PathProviderApi.getExternalStoragePaths"

    invoke-direct {v2, p0, v4, v3, v1}, Lj0/a;-><init>(Lj0/c;Ljava/lang/String;Lj0/i;Lj0/c$c;)V

    if-eqz p1, :cond_6

    new-instance p0, Lo0/h;

    invoke-direct {p0, p1}, Lo0/h;-><init>(Lo0/a$b;)V

    invoke-virtual {v2, p0}, Lj0/a;->e(Lj0/a$d;)V

    goto :goto_6

    :cond_6
    invoke-virtual {v2, v0}, Lj0/a;->e(Lj0/a$d;)V

    :goto_6
    return-void
.end method
