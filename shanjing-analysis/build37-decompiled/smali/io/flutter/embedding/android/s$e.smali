.class Lio/flutter/embedding/android/s$e;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lio/flutter/embedding/engine/renderer/a;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lio/flutter/embedding/android/s;->A(Ljava/lang/Runnable;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic a:Lio/flutter/embedding/engine/renderer/FlutterRenderer;

.field final synthetic b:Ljava/lang/Runnable;

.field final synthetic c:Lio/flutter/embedding/android/s;


# direct methods
.method constructor <init>(Lio/flutter/embedding/android/s;Lio/flutter/embedding/engine/renderer/FlutterRenderer;Ljava/lang/Runnable;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    iput-object p1, p0, Lio/flutter/embedding/android/s$e;->c:Lio/flutter/embedding/android/s;

    iput-object p2, p0, Lio/flutter/embedding/android/s$e;->a:Lio/flutter/embedding/engine/renderer/FlutterRenderer;

    iput-object p3, p0, Lio/flutter/embedding/android/s$e;->b:Ljava/lang/Runnable;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public c()V
    .locals 0

    return-void
.end method

.method public f()V
    .locals 2

    iget-object v0, p0, Lio/flutter/embedding/android/s$e;->a:Lio/flutter/embedding/engine/renderer/FlutterRenderer;

    invoke-virtual {v0, p0}, Lio/flutter/embedding/engine/renderer/FlutterRenderer;->u(Lio/flutter/embedding/engine/renderer/a;)V

    iget-object v0, p0, Lio/flutter/embedding/android/s$e;->b:Ljava/lang/Runnable;

    invoke-interface {v0}, Ljava/lang/Runnable;->run()V

    iget-object v0, p0, Lio/flutter/embedding/android/s$e;->c:Lio/flutter/embedding/android/s;

    iget-object v1, v0, Lio/flutter/embedding/android/s;->d:Lio/flutter/embedding/engine/renderer/b;

    instance-of v1, v1, Lio/flutter/embedding/android/k;

    if-nez v1, :cond_0

    invoke-static {v0}, Lio/flutter/embedding/android/s;->i(Lio/flutter/embedding/android/s;)Lio/flutter/embedding/android/k;

    move-result-object v0

    if-eqz v0, :cond_0

    iget-object v0, p0, Lio/flutter/embedding/android/s$e;->c:Lio/flutter/embedding/android/s;

    invoke-static {v0}, Lio/flutter/embedding/android/s;->i(Lio/flutter/embedding/android/s;)Lio/flutter/embedding/android/k;

    move-result-object v0

    invoke-virtual {v0}, Lio/flutter/embedding/android/k;->a()V

    iget-object v0, p0, Lio/flutter/embedding/android/s$e;->c:Lio/flutter/embedding/android/s;

    invoke-static {v0}, Lio/flutter/embedding/android/s;->j(Lio/flutter/embedding/android/s;)V

    :cond_0
    return-void
.end method
