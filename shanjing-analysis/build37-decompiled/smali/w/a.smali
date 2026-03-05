.class public final Lw/a;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lw/a$b;
    }
.end annotation


# static fields
.field private static e:Lw/a;

.field private static f:Z


# instance fields
.field private a:Lz/d;

.field private b:Ly/a;

.field private c:Lio/flutter/embedding/engine/FlutterJNI$c;

.field private d:Ljava/util/concurrent/ExecutorService;


# direct methods
.method private constructor <init>(Lz/d;Ly/a;Lio/flutter/embedding/engine/FlutterJNI$c;Ljava/util/concurrent/ExecutorService;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lw/a;->a:Lz/d;

    iput-object p2, p0, Lw/a;->b:Ly/a;

    iput-object p3, p0, Lw/a;->c:Lio/flutter/embedding/engine/FlutterJNI$c;

    iput-object p4, p0, Lw/a;->d:Ljava/util/concurrent/ExecutorService;

    return-void
.end method

.method synthetic constructor <init>(Lz/d;Ly/a;Lio/flutter/embedding/engine/FlutterJNI$c;Ljava/util/concurrent/ExecutorService;Lw/a$a;)V
    .locals 0

    invoke-direct {p0, p1, p2, p3, p4}, Lw/a;-><init>(Lz/d;Ly/a;Lio/flutter/embedding/engine/FlutterJNI$c;Ljava/util/concurrent/ExecutorService;)V

    return-void
.end method

.method public static e()Lw/a;
    .locals 1

    const/4 v0, 0x1

    sput-boolean v0, Lw/a;->f:Z

    sget-object v0, Lw/a;->e:Lw/a;

    if-nez v0, :cond_0

    new-instance v0, Lw/a$b;

    invoke-direct {v0}, Lw/a$b;-><init>()V

    invoke-virtual {v0}, Lw/a$b;->a()Lw/a;

    move-result-object v0

    sput-object v0, Lw/a;->e:Lw/a;

    :cond_0
    sget-object v0, Lw/a;->e:Lw/a;

    return-object v0
.end method


# virtual methods
.method public a()Ly/a;
    .locals 1

    iget-object v0, p0, Lw/a;->b:Ly/a;

    return-object v0
.end method

.method public b()Ljava/util/concurrent/ExecutorService;
    .locals 1

    iget-object v0, p0, Lw/a;->d:Ljava/util/concurrent/ExecutorService;

    return-object v0
.end method

.method public c()Lz/d;
    .locals 1

    iget-object v0, p0, Lw/a;->a:Lz/d;

    return-object v0
.end method

.method public d()Lio/flutter/embedding/engine/FlutterJNI$c;
    .locals 1

    iget-object v0, p0, Lw/a;->c:Lio/flutter/embedding/engine/FlutterJNI$c;

    return-object v0
.end method
