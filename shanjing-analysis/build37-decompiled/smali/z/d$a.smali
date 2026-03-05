.class Lz/d$a;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ljava/util/concurrent/Callable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lz/d;->o(Landroid/content/Context;Lz/d$c;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Object;",
        "Ljava/util/concurrent/Callable<",
        "Lz/d$b;",
        ">;"
    }
.end annotation


# instance fields
.field final synthetic a:Landroid/content/Context;

.field final synthetic b:Lz/d;


# direct methods
.method constructor <init>(Lz/d;Landroid/content/Context;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    iput-object p1, p0, Lz/d$a;->b:Lz/d;

    iput-object p2, p0, Lz/d$a;->a:Landroid/content/Context;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static synthetic a(Lz/d$a;)V
    .locals 0

    invoke-direct {p0}, Lz/d$a;->c()V

    return-void
.end method

.method private synthetic c()V
    .locals 1

    iget-object v0, p0, Lz/d$a;->b:Lz/d;

    invoke-static {v0}, Lz/d;->b(Lz/d;)Lio/flutter/embedding/engine/FlutterJNI;

    move-result-object v0

    invoke-virtual {v0}, Lio/flutter/embedding/engine/FlutterJNI;->prefetchDefaultFontManager()V

    return-void
.end method


# virtual methods
.method public b()Lz/d$b;
    .locals 6

    const-string v0, "FlutterLoader initTask"

    invoke-static {v0}, Lp0/f;->f(Ljava/lang/String;)Lp0/f;

    move-result-object v0

    :try_start_0
    iget-object v1, p0, Lz/d$a;->b:Lz/d;

    iget-object v2, p0, Lz/d$a;->a:Landroid/content/Context;

    invoke-static {v1, v2}, Lz/d;->a(Lz/d;Landroid/content/Context;)Lz/e;

    iget-object v1, p0, Lz/d$a;->b:Lz/d;

    invoke-static {v1}, Lz/d;->b(Lz/d;)Lio/flutter/embedding/engine/FlutterJNI;

    move-result-object v1

    invoke-virtual {v1}, Lio/flutter/embedding/engine/FlutterJNI;->loadLibrary()V

    iget-object v1, p0, Lz/d$a;->b:Lz/d;

    invoke-static {v1}, Lz/d;->b(Lz/d;)Lio/flutter/embedding/engine/FlutterJNI;

    move-result-object v1

    invoke-virtual {v1}, Lio/flutter/embedding/engine/FlutterJNI;->updateRefreshRate()V

    iget-object v1, p0, Lz/d$a;->b:Lz/d;

    invoke-static {v1}, Lz/d;->c(Lz/d;)Ljava/util/concurrent/ExecutorService;

    move-result-object v1

    new-instance v2, Lz/c;

    invoke-direct {v2, p0}, Lz/c;-><init>(Lz/d$a;)V

    invoke-interface {v1, v2}, Ljava/util/concurrent/Executor;->execute(Ljava/lang/Runnable;)V

    new-instance v1, Lz/d$b;

    iget-object v2, p0, Lz/d$a;->a:Landroid/content/Context;

    invoke-static {v2}, Lp0/c;->d(Landroid/content/Context;)Ljava/lang/String;

    move-result-object v2

    iget-object v3, p0, Lz/d$a;->a:Landroid/content/Context;

    invoke-static {v3}, Lp0/c;->a(Landroid/content/Context;)Ljava/lang/String;

    move-result-object v3

    iget-object v4, p0, Lz/d$a;->a:Landroid/content/Context;

    invoke-static {v4}, Lp0/c;->c(Landroid/content/Context;)Ljava/lang/String;

    move-result-object v4

    const/4 v5, 0x0

    invoke-direct {v1, v2, v3, v4, v5}, Lz/d$b;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lz/d$a;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Lp0/f;->close()V

    :cond_0
    return-object v1

    :catchall_0
    move-exception v1

    if-eqz v0, :cond_1

    :try_start_1
    invoke-virtual {v0}, Lp0/f;->close()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_0

    :catchall_1
    move-exception v0

    invoke-virtual {v1, v0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_1
    :goto_0
    throw v1
.end method

.method public bridge synthetic call()Ljava/lang/Object;
    .locals 1

    invoke-virtual {p0}, Lz/d$a;->b()Lz/d$b;

    move-result-object v0

    return-object v0
.end method
