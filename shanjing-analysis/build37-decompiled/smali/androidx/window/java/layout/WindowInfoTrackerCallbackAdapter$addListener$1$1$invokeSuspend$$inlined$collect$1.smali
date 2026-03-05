.class public final Landroidx/window/java/layout/WindowInfoTrackerCallbackAdapter$addListener$1$1$invokeSuspend$$inlined$collect$1;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lk1/c;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Landroidx/window/java/layout/WindowInfoTrackerCallbackAdapter$addListener$1$1;->invokeSuspend(Ljava/lang/Object;)Ljava/lang/Object;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = null
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Object;",
        "Lk1/c<",
        "TT;>;"
    }
.end annotation


# instance fields
.field final synthetic $consumer$inlined:Landroidx/core/util/a;


# direct methods
.method public constructor <init>(Landroidx/core/util/a;)V
    .locals 0

    iput-object p1, p0, Landroidx/window/java/layout/WindowInfoTrackerCallbackAdapter$addListener$1$1$invokeSuspend$$inlined$collect$1;->$consumer$inlined:Landroidx/core/util/a;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public emit(Ljava/lang/Object;Ls0/d;)Ljava/lang/Object;
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;",
            "Ls0/d<",
            "-",
            "Lq0/q;",
            ">;)",
            "Ljava/lang/Object;"
        }
    .end annotation

    iget-object p2, p0, Landroidx/window/java/layout/WindowInfoTrackerCallbackAdapter$addListener$1$1$invokeSuspend$$inlined$collect$1;->$consumer$inlined:Landroidx/core/util/a;

    invoke-interface {p2, p1}, Landroidx/core/util/a;->accept(Ljava/lang/Object;)V

    sget-object p1, Lq0/q;->a:Lq0/q;

    return-object p1
.end method
